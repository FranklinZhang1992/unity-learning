#=====================================================================================
#
#  Copyright (c) 2007-2008 Stratus Technologies Bermuda Ltd.  All rights reserved
#  Confidential and proprietary.
#
#  No part of this page may be used, re-distributed, copied, re-published or
#  re-written without prior express written consent
#
#=====================================================================================

require 'yaml'
require 'fileutils'
require 'set'
require 'thread'
require 'inotifywait'
require 'hoard/syncer'

class HoardError < RuntimeError ; end
class ObjectAlreadyManaged < HoardError ; end

class Object
    def local_node_hoard_name_re
        return @__local_node_hoard_name_re if @__local_node_hoard_name_re
        if $UUID
            @__local_node_hoard_name_re = Regexp.new("^nodes/#{$UUID}")
        end
        @__local_node_hoard_name_re
    end
end

class Module
    def artifact
        class << self
            def inherited(subclass)
                # maybe dunna need this anymore
            end

            def properties() const_get(:HoardProperties).clone rescue Hash.new end
        end

        define_method(:id) { self.uuid }
        define_method(:uuid) {
            uuid = instance_variable_get("@uuid")
            if uuid.nil?
                uuid = Kernel.uuid
                instance_variable_set("@uuid", uuid)
            end
            uuid
        }
        define_method(:hoard) { instance_variable_get("@__hoard__") }
        # XXX maybe only define this if it is not yet defined
        define_method(:natural_key) { nil }

        define_method(:__hoard_load__) {
            self.class.properties.each_key { |property| self.send("#{property}_load") }
        }

        define_method(:property_lock) {
            if @property_lock.nil?
                @property_lock = Monitor.new
            end
            @property_lock
        }

        # Is this object persisted under the local node's directory structure?
        define_method(:is_local?) {
            hoard = instance_variable_get('@__hoard__')
            return nil if hoard.nil? || local_node_hoard_name_re.nil?
            local_node_hoard_name_re.match(hoard.name) ? true : false
        }
    end

    # Add the given YAML-encoded hoard properties to this class
    def property(*symbols)
        symbols.each do |symbol|
            property_cfg(symbol, :type => :yaml)
        end
    end

    # Add a hoard property to this class with the given configuration:
    #   :type => <:yaml|:string|:xml>,
    def property_cfg(symbol, cfg={})
        cfg[:type] ||= :yaml
        properties = Hash.new
        begin
            properties = const_get(:HoardProperties)
        rescue NameError => e
            properties = Hash.new
            const_set(:HoardProperties, properties)
        end
        unless const_defined?(:HoardProperties)
            properties = properties.clone
            const_set(:HoardProperties, properties)
        end
        properties[symbol.to_sym] = cfg

        define_method(symbol) {
            # check last read time?
            hoard = instance_variable_get('@__hoard__')
            if hoard.nil?
                return instance_variable_get("@#{symbol}")
            else
                return hoard.get_property(self, symbol)
            end
        }

        define_method("#{symbol}=") { |value|
            hook = "#{symbol.to_s}_setter_hook".intern
            old = instance_variable_get("@#{symbol}")
            if self.respond_to? hook
                self.send(hook, old, value) if old != value
            end
            if hoard
                hoard.set_property(self, symbol, value)
            else
                instance_variable_set("@#{symbol}", value)
            end
            hook = "#{symbol.to_s}_setter_post_hook".intern
            if self.respond_to? hook
                self.send(hook, old, value) if old != value
            end
        }

        define_method("#{symbol}_load") {
            hoard = instance_variable_get('@__hoard__')
            return if hoard.nil?
            old_value, value = hoard.load_property(self, symbol)
            hook = "#{symbol.to_s}_load_hook".intern
            if self.respond_to?(hook) && old_value != value
                self.send(hook, old_value, value)
            end
            [old_value, value]
        }

        define_method("#{symbol}_sync") {
            hoard = instance_variable_get('@__hoard__')
            return if hoard.nil?
            hoard.sync(self.uuid, symbol)
            hook = "#{symbol.to_s}_sync_hook".intern
            self.send(hook) if self.respond_to? hook
        }
    end
end

class Hoard
    attr_reader :controller
    attr_reader :name
    attr_reader :factory
    attr_reader :dir
    attr_reader :generation  # can tell whether the collection has changed members
    private :dir

    def each() values.each {|d| yield d} end
    include Enumerable
    def length() @membership_lock.synchronize { @objects.length } end
    def empty?() @membership_lock.synchronize { @objects.empty? } end
    def values() @membership_lock.synchronize { @objects.values } end
    def <<(obj) add(obj) end

    @@class_lock = Monitor.new
    @@inotify_wait = nil
    def Hoard.inotify()
        @@class_lock.synchronize {
            unless @@inotify_wait
                # @@inotify_wait = InotifyWait.new($config, [:delete, :modify, :create, :moved_to])
                @@inotify_wait = InotifyWait.new($config, [:modify, :create, :moved_to, :moved_from])
            end
        }
        @@inotify_wait
    end

    @@uuid_regexp = /^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$/
    def Hoard.is_uuid?(str)
        return @@uuid_regexp.match(str)
    end

    def Hoard.path_to_class_type(fullpath)
        begin
            typename = IO.read(fullpath)
        # rescue Errno::ENOENT
        rescue Exception => exception
            logException('no class for hoard object', exception)
            raise TypeError, "Type cannot be determined from #{fullpath} - file does not exist"
        end
        type = typename.split('::').inject(Module) do |m,c|
            begin
                m = m.const_get(c)
            rescue NameError => err
                raise TypeError, "Hoard class #{typename} does not exist - #{err} - maybe this is a deprecated class from an old Avance release?"
            end
        end
        raise TypeError, "unknown hoard class '#{typename}'" if type.nil?
        type
    end

    #
    # There needs to be hoards for both the local node and for phantom nodes. The phantom
    # hoards must get their information from the PhantomNode object, and not from local
    # services.  The local hoards must get their information from the local node service.
    # The information they need to get includes connections between various objects in
    # topology ... like the connection between a disk and its partitions, and the connection
    # between a storage plex and the backing disk.  These connections are made using the
    # uuid's of these object and not direct object references, since they must be reloaded
    # the hoard and the references to in memory objects can not be persisted.  The
    # uuid references must then be looked up from a hoard (the current hoard -- like the
    # platform hoard, or a different hoard, like the storage hoard).
    #
    # To support these connections, hoards now have a reference to their controller.  This
    # allows an object in a hoard to find its managing node and thus the other hoards that
    # represent data for that hoard.  The 'controller' argument below generates that connection.
    #

    def initialize(controller, name, factory)
        @controller = controller
        @name = name
        raise TypeError, "factory must be an artifact" unless factory.respond_to? :properties
        @factory = factory
        @dir = File.join( $config, name )
        @trash = File.join( @dir, '.trash' )
        @generation = 1
        @objects = Hash.new
        @object_watch = Hash.new  # Watches for specific objects within this hoard
        @watches = []  # Watches for the hoard itself
        @membership_lock = Monitor.new  # Locks @objects, @object_watch, and @watches

        logDebug {"created hoard for #{@name}, factory #{factory}"}
        FileUtils::mkdir_p @trash

        @membership_lock.synchronize do
            @notify_handles = []
            @notify_handles << Hoard.inotify.add_watch(@dir, [:create, :fake], lambda { |path, events, uuid|
                next unless uuid # The directory itself was created if there's no file component (the UUID)
                next unless Hoard.is_uuid?(uuid)
                @membership_lock.synchronize do
                    if __skip_uuid_dir_of_trashed_object__(uuid)
                        logDebug {"#{factory} object create from trash, cleaning #{uuid}"}
                        next
                    end
                    obj = self[uuid]
                    if obj.nil?
                        logDebug { "#{factory} autoload create a new object #{path}/#{uuid}" }
                    end
                end

                # Load the object into the hoard
                load(uuid)
            })
            @notify_handles << Hoard.inotify.add_watch(@dir, [:delete, :delete_self, :moved_from], lambda { |path, events, uuid|
                uuid or raise "No UUID (file) for a #{@factory} hoard delete event (path=#{path})"
                next unless Hoard.is_uuid?(uuid)
                obj = nil
                @membership_lock.synchronize do
                    obj = self[uuid]
                    if obj
                        __unmanage__(obj)
                    end
                end
                logDebug { "#{factory} autoload delete on #{path}/#{uuid}" } if obj
            })
        end
        
        self.__load_all__
    end

    # Tear down the hoard object (stop listening to inotify's etc)
    def free
        @membership_lock.synchronize do
            @notify_handles.each { |handle| Hoard.inotify.delete_watch(handle) }
            @objects.values.each {|object|
                __unmanage__(object)
            }
            @objects = nil
        end
    end

    def [] (value, key=:uuid)
        @membership_lock.synchronize do
            return @objects[value] if key == :uuid
            return @objects.values.detect {|o| o.send(key) == value}
        end
    end

    def mkdir(subdir)
        Dir.mkdir( File.join(@dir,subdir) )
    end

    def symlink(target, linkname)
        return if linkname.nil?
        link = File.join(@dir, linkname)
        delete_symlink(linkname)
        File.symlink(target, link)
    end

    def delete_symlink(linkname)
        return if linkname.nil?
        fullpath = absolute_path(linkname)
        case
        when File.symlink?(fullpath) ;
             Kernel.ignore("error removing symlink '#{fullpath}'") { File.unlink(fullpath) }
        when File.exists?(fullpath) ;
             Kernel.ignore("error removing file|dir '#{fullpath}'") { File.unlink(fullpath) }
        else return
        end
        path = relative_path(linkname)
        Syncer.delete(path)
    end

    def sync(dir, file=nil)
        dir = dir.chomp('/')
        if (File.exists?(absolute_path(dir)) && !File.directory?(absolute_path(dir))) # This really screws up the files with rsync
            raise "Hoard#sync() cannot sync dir '#{name}/#{dir}', because it is a file, not a directory!"
        end

        path = "#{name}/#{dir}/#{file}"
        if file == 'class'
            Syncer.create(path)
        else
            Syncer.add(path)
        end
    end

    def refresh_all
        logNotice{"Refresh of #{@dir}"} if $debug > 0 # by #{caller.join("\n")}"} 

        @objects.values.each do |object|

        # Refresh all properties from the hoard, 
        # and save the old/new values if a hook must be called with them

            property_load_hooks = { }
            @membership_lock.synchronize do
                object.class.properties.each_key do |property|
                    old_value, value = load_property(object, property)
                    logNotice{"Found prop #{property}: #{old_value}, now #{value} "} if $debug > 2
                    hook = "#{property}_load_hook".intern
                    if object.respond_to?(hook) && old_value != value
                        logNotice{"Updating prop #{object.uuid}/#{property}: #{old_value}->#{value} "}
                        property_load_hooks[hook] = [old_value, value]  # Defer calling hooks until outside the lock
                    end
                end
            end

            # Call all relevant hooks now that we're outside the lock
            property_load_hooks.each_key do |hook|
                old_value, value = property_load_hooks[hook]
                object.send(hook, old_value, value)
            end
        end
    rescue Exception => err
        logException("Hoard#refresh(#{@dir}) exception", err)
        raise
    end

    def __load_all__
        logNotice{"Load of #{@dir}"} # by #{caller.join("\n")}"}
        files = Dir.glob("#{@dir}/????????-????-????-????-????????????")
        files.each do |filename|
            uuid = File.basename(filename)
            if __skip_uuid_dir_of_trashed_object__(uuid)
                logDebug {"object load from trash, cleaning #{uuid}"}
                next
            end

            # Load the object into the hoard
            load(uuid)
        end
    end

    def all(type) @membership_lock.synchronize { @objects.values.grep(type) } end

    def add(object)
        raise TypeError, "object must be an artifact" unless object.class.respond_to? :properties
        raise "Hoard add cannot add a #{object.class.to_s} object because the uuid is invalid (#{object.uuid})" unless Hoard.is_uuid?(object.uuid)

        # Check...
        key = object.natural_key

        @membership_lock.synchronize do
            existing = @objects[object.uuid]
            if !key.nil? and existing.nil?
                existing = @objects.values.detect { |o| o.natural_key == key }
            end
            return existing unless existing.nil?

            __manage__(object)

            tmpdir = ".#{object.uuid}"
            if File.directory?(absolute_path(tmpdir))
                # Stale temp directory must be left over from an asynchronous restart of spine in the middle of this very same operation
                FileUtils::rm_rf(absolute_path(tmpdir))
            end
            mkdir(tmpdir)

            # Persist all properties and the class file
            # logDebug {"store properties for #{object.class}"}
            object.class.properties.each_key { |property| store_property(object, property, tmpdir) }
            open("#{tmpdir}/class", 'w') {|o| o.print object.class}

            # logDebug {"rename #{tmpdir} => #{self.uuid}"}
            rename(tmpdir, object.uuid)
            symlink(object.uuid, object.name) if object.respond_to?(:name)

            # Sync all properties (class file last)
            object.class.properties.each_key { |property| self.sync(object.uuid, property.to_s) }
            self.sync(object.uuid, 'class') # Sync class file last since that causes the object to be created
        end
        object
    rescue Exception => err
        logException("Hoard#add(#{object.class}) exception", err)
        raise
    end

    # Like add() but for pre-existing objects being loaded from the hoard
    def load(uuid)
        unless Hoard.is_uuid?(uuid)
            logWarning {"Hoard add #{@factory} - #{uuid} is not a UUID"}
            return nil
        end

        class_file = "#{absolute_path(uuid)}/class"
        wait = 0.5
        # XXX This wants to change such that we do not need this check -- what I
        # mean is that the data needs to show up all at once (maybe a dir rename).
        until File.exists? class_file
            if wait > 16
                logError {"timed out waiting for class file #{uuid}"}
                raise TypeError, "cannot determine class of object #{uuid} - no class file"
            end
            Thread.pass
            sleep wait
            wait = wait * 2
        end

        type = Hoard.path_to_class_type("#{absolute_path(uuid)}/class")
        raise TypeError, "#{type.to_s} is not a class" unless type.instance_of? Class
        raise TypeError, "#{type.to_s} class is not an artifact" unless type.respond_to? :properties
        object = type.allocate
        object.instance_variable_set("@uuid", uuid)

        # load hooks to call and the old/new values to pass
        property_load_hooks = { }

        @membership_lock.synchronize do
            if __skip_uuid_dir_of_trashed_object__(object.uuid)
                logDebug {"object load from trash, skipping #{uuid}"}
                return nil
            end

            existing = @objects[object.uuid]
            return existing unless existing.nil?

            __manage__(object)

            # Load all properties from the hoard, and save the old/new values if a hook must be called with them
            object.class.properties.each_key do |property|
                old_value, value = load_property(object, property)
                logNotice{"Load prop #{property}: #{old_value}, now #{value} "} if $debug > 2
                hook = "#{property}_load_hook".intern
                if object.respond_to?(hook) && old_value != value
                    property_load_hooks[hook] = [old_value, value]  # Defer calling hooks until outside the lock
                end
            end
        end

        # Call all relevant hooks now that we're outside the lock
        object.send(:init_hook) if object.respond_to? :init_hook
        property_load_hooks.each_key do |hook|
            old_value, value = property_load_hooks[hook]
            object.send(hook, old_value, value)
        end
        object.send(:load_hook) if object.respond_to? :load_hook

        object
    rescue TypeError => err
        logError {err.to_s}
        nil
    rescue Exception => err
        logException("Hoard#load(#{uuid}) exception", err)
        raise
    end


    def __trash__(object) __trash_uuid__(object.uuid) end
    def __trash_uuid__(uuid)
        obj_path = "#{@dir}/#{uuid}"
        return unless File.exists?(obj_path)

        trash_path = "#{@trash}/#{uuid}"
        if File.exists?(trash_path)
            logError {"spine hoard bug - the object #{uuid} is already in the trash so we shouldn't have to delete it again"}
        else
            File.touch(trash_path)
        end
        Dir.unlink!(obj_path)
    end

    def delete(object)
        logDebug { "#{object.class} user delete on #{name}/#{object.uuid}" }
        __delete__(object)
    end

    def __delete__(object)
        # No events while we're removing the object
        uuid = object.uuid
        @membership_lock.synchronize do
            __unmanage__(object)
            # FileUtils::rm_rf(absolute_path(uuid))
            __trash__(object)
        end

        path = relative_path(uuid)
        Syncer.delete(path)
        delete_symlink(object.name) if object.respond_to? :name
    end

    def relative_path(path) "#{@name}/#{path}" end
    # You should not need to do all that err checking...
    def absolute_path(path)
        raise ArgumentError, "path is nil" if path.nil?
        raise ArgumentError, "path is an empty string" if path.to_s.length == 0
        File.join( @dir, path )
    end

    def open(path, mode='r', &block)
        File.open(absolute_path(path), mode, &block)
    end

    def rename(oldpath, newpath)
        File.rename(absolute_path(oldpath), absolute_path(newpath))
    end

    def manages?(object)
        manager = object.hoard
        return false if manager.nil?
        raise ObjectAlreadyManaged unless manager == self
        @membership_lock.synchronize {
            return false if @objects[object.uuid].nil?
        }
        return true
    end

    def load_property(object, property)
        value, old_value = nil, nil
        filename = "#{object.uuid}/#{property}"
        path = absolute_path(filename)
        object.property_lock.synchronize {
            old_value = object.instance_variable_get("@#{property}")

            begin
                object.instance_variable_set("@__#{property}_timestamp__", Time.now)
                data = IO.read(absolute_path(filename))
                # YAML translates 0 length string to false,
                # which is not what we want - we want nil
                if data.length == 0
                    # value remains nil
                elsif data.slice(0,3) == '---'
                    value = YAML.load(data)
                else
                    value = data
                end
            rescue Errno::ENOENT => err
                # Hoard property file doesn't exist
                if old_value and object.instance_variable_get('@__hoard__') # May be in process of being deleted while property is being read
                    # Leave in-memory property value for now, in case the object is about to be deleted
                    value = old_value
                    if check_object_is_deleted(object)
                        logInfo { "Loading hoard property #{filename}, but the object was really deleted!" }
                    else
                        tries = 3
                        del_count = object.instance_variable_get("@__#{property}_deleted_count__") || 0
                        if del_count <= tries
                            del_count += 1
                            object.instance_variable_set("@__#{property}_deleted_count__", del_count)
                            if del_count == tries  # Log this message one time, after waiting #{tries} times
                                logBug { "Error loading hoard property #{filename}', property file used to exist but was deleted!" }
                            end
                        end
                    end
                end
            rescue Exception => err
                unless @load_property_exception_logged
                    logException("Error loading hoard property #{property} on a #{object.class} object", err)
                    @load_property_exception_logged = true
                end
            end

            # Do this before the load_hook to allow the load_hook do a "set"
            # and/or a "sync" if it wants to.
            object.instance_variable_set("@#{property}", value)
        }
        [old_value, value]  # Return the transition from -> to
    end

    def set_property(object, property, value)
        object.property_lock.synchronize {
            object.instance_variable_set("@#{property}", value)
            store_property(object, property)
        }
        object.send("#{property}_sync".intern)
    end

    def get_property(object, property)
        property_instance_var = "@#{property}"
        path = absolute_path("#{object.uuid}/#{property}")
        
        timestamp = object.instance_variable_get("@__#{property}_timestamp__")
        if timestamp.nil? 
            Thread.current['hoard_refreshes'] = 1 + (Thread.current['hoard_refreshes']||0)
            old_value, value = object.send("#{property}_load")
        end
        object.instance_variable_get(property_instance_var)
    end

    def store_property(object, property, dir=nil)
        dir ||= object.uuid
        object.property_lock.synchronize {
            value = object.instance_variable_get("@#{property}")
            path = "#{dir}/#{property}"
            newfile = "#{dir}/#{property}.#{$UUID}"
            open(newfile, 'w') {|o|
                if object.class.properties[property.to_sym][:type] == :yaml
                    YAML.dump(value, o)
                else
                    o.write(value)
                end
                o.fsync
            }
            object.instance_variable_set("@__#{property}_timestamp__", Time.now)
            rename(newfile, path)
        }
    end

    # Return true if the object has been deleted (and cleanup after it), false if all is normal
    def check_object_is_deleted(object)
        deleted = false
        if File.exists?(File.join(@trash, object.uuid))
            logWarning { "Trash file #{name}/.trash/#{object.uuid} exists, deleting object from memory and from the hoard" }
            deleted = true
        elsif not File.exists?(absolute_path("#{object.uuid}/class"))
            # Object class file is gone, might as well delete the object
            logWarning { "Class file #{name}/#{object.uuid}/class has been deleted, deleting object from memory and from the hoard" }
            deleted = true
        end
        __delete__(object) if deleted
        deleted
    end

    # Manage the object as part of the hoard.
    def __manage__(object)
        return object if self.manages?(object)
        uuid = object.uuid
        object.instance_variable_set('@__hoard__', self)
        @generation += 1
        @objects[uuid] = object
        __watch__(object)
    end

    # Manage the object as part of the hoard.
    def __watch__(object)
        uuid = object.uuid
        @object_watch[uuid] = Hoard.inotify.add_watch( "#{@dir}/#{uuid}",
           [:create, :modify, :delete, :delete_self, :moved_to, :moved_from],
           lambda {|path, events, filename|
               if filename
                   method = "#{filename}_load"  # If filename is a property, then it will have a "#{property}_load" method

                   # respond_to? creates symbols (which are never garbage-collected). This method is called
                   # with names like .property_XXXXXX (remote node) or property.UUID (local node), until
                   # finally called with the correct name. The right fix would be to get the object's method
                   # list, convert to strings, and check if method is in the list. But this seems inefficient.
                   # Fortunately, the names contain dots, which aren't valid in method names.
                   unless method.include?(".") 
                       object.send(method) if object.respond_to?(method)
                   end
               end
           }
        )
    end

    # Unmanage (stop managing) the object.
    def __unmanage__(object)
        manager = object.instance_variable_get('@__hoard__') or return
        raise "Artifact (uuid=#{object.uuid}) is managed by a different hoard" unless manager == self
        object.instance_variable_set('@__hoard__', nil)
        @generation += 1
        uuid = object.uuid
        @objects.delete(uuid)
        __unwatch__(object)
    end

    # Unmanage (stop managing) the object.
    def __unwatch__(object)
        uuid = object.uuid
        @object_watch[uuid] or return
        Hoard.inotify.delete_watch(@object_watch[uuid])
        @object_watch.delete(uuid)
    end

    # Check a UUID to see if it is in the trash.
    # If it is, delete (cleanup) the object directory if it exists.
    # Returns true if the object is in the trash, otherwise false.
    def __skip_uuid_dir_of_trashed_object__(uuid)
        if File.exists? File.join(@trash, uuid)
            obj_dir = File.join(@dir,uuid)
            Dir.unlink!(obj_dir) if File.exists?(obj_dir)
            true
        else
            false
        end
    end
end

# Local Variables:
# mode: ruby
# ruby-indent-level: 4
# End:
# vim:expandtab
# vim:autoindent
