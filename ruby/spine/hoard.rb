require 'fileutils'
require 'yaml'
require 'set'
require 'thread'
require 'hoard/syncer'

class  Module
	def artifact
		class << self
			def inherited(subclass)
			end
			def properties()
				const_get(:HoardProperties).clone
			rescue
				Hash.new 
			end	
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
		define_method(:__hoard_load__) {
			self.class.properties.each_key { |property|
				self.send("#{property}_load")
			}
		}
		define_method(:property_lock) {
			if @property_lock.nil?
				@property_lock = Monitor.new
			end
			@property_lock
		}
	end

	def property(*symbols)
		symbols.each do |symbol|
			property_cfg(symbol, :type => :yaml)
		end
	end

	def property_cfg(symbol, cfg = {})
		# logDebug { "property cfg #{symbol}, #{cfg}" }
		cfg[:type]  ||= :yaml
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
			hoard = instance_variable_get('@__haord__')
			return if hoard.nil?
			old_value, value = hoard.load_property(self, symbol)
			hook = "#{symbol.to_s}_load_hook".intern
			if self.respond_to?(hook) && old_value != value
				self.send(hook, old_value_value)
			end
			[old_value, value]
		}

		define_method("#{symbol}_sync") {
			hoard = instance_variable_get('@__hoard__')
			return if hoard.nil?
			hoard.sync(self.id, symbol)
			hook = "#{symbol.to_s}_sync_hook".intern
			self.send(hook) if self.respond_to? hook
		}
	end
end

class Hoard
	include Enumerable
	def initialize(controller, name, factory)
		@controller = controller
		@name = name
		@factory = factory
		@dir = File.join($config, name)
		@trash = File.join(@dir, '.trash')
		@objects = Hash.new
		@membership_lock = Monitor.new
		logDebug { "created hoard for #{@name}, factory #{factory}" }
		FileUtils::mkdir_p @trash
		self.__load_all__
	end

	@@uuid_regexp = /^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$/
	def Hoard.is_uuid?(str)
		return @@uuid_regexp.match(str)
	end

	def Hoard.path_to_class_type(fullpath)
		begin
			typename = IO.read(fullpath)
		rescue Exception => exception
			logWarning {"no class for hoard object => #{exception}"}
			raise TypeError, "Type cannot be determined from #{fullpath} - file does not exist"
		end
		type = typename.split('::').inject(Module) do |m, c|
			begin
				m = m.const_get(c)
			rescue Exception => e
				raise TypeError, "Hoard class #{typename} does not exist => #{e}"
			end
		end
		raise TypeError, "unknown hoard class '#{typename}'" if type.nil?
		type
	end

	def __load_all__
		logNotice {"Load of #{@dir}"}
		files = Dir.glob("#{@dir}/????????-????-????-????-????????????")
		files.each do |filename|
			uuid = File.basename(filename)
			if __skip_uuid_dir_of_trashed_object__(uuid)
				logDebug {"Object load from trash, cleaning #{uuid}"}
				next
			end
			load(uuid)
		end
	end

	def load(uuid)
		unless Hoard.is_uuid?(uuid)
			logWarning {"Hoard add #{@factory} - #{uuid} is not a UUID"}
		    return nil
		end
		class_file = "#{absolute_path(uuid)}/class"
		wait = 0.5
		until File.exists? class_file
			if wait > 16
				logWarning {"Time out waiting for class file #{uuid}"}
				raise TypeError, "Cannot determined class of object #{uuid} - no class file"
			end
			Thread.pass
			sleep wait
			wait = wait *2
		end
		type = Hoard.path_to_class_type("#{absolute_path(uuid)}/class")
		raise TypeError, "#{type.to_s} is not a class" unless type.instance_of? Class
		raise TypeError, "#{type.to_s} class is not an artifact" unless type.respond_to? :properties
		object = type.allocate
		object.instance_variable_set("@uuid", uuid)

		property_load_hooks = {}
		@membership_lock.synchronize do
			if __skip_uuid_dir_of_trashed_object__(object.uuid)
				logDebug {"object load from trash, skipping #{uuid}"}
				return nil
			end
			existing = @objects[object.uuid]
			return existing unless existing.nil?

			__manage__(object)
			object.class.properties.each_key do |property|
				old_value, value = load_property(object, property)
				logNotice {"Load prop #{property}: #{old_value}, now #{value}"} if $debug > 2
				hook = "#{property}_load_hook".intern
				if object.respond_to?(hook) && old_value != value
					property_load_hooks[hook] = [old_value, value]
				end
			end
		end

		object.send(:init_hook) if object.respond_to? :init_hook
		property_load_hooks.each_key do |hook|
			old_value, value = property_load_hooks[hook]
			object.send(hook, old_value, value)
		end
		object.send(:load_hook) if object.respond_to? :load_hook
		object
	end

	def each
		logDebug {"call method each in Hoard"}
		values.each { |d|
			yield d
		}
	end
	def length
		@objects.length
	end
	def empty?
		@objects.empty?
	end
	def values
		@objects.values
	end
	def <<(obj)
		add(obj)
	end
	def [] (value, key=:uuid)
		logDebug {"call method [] in Hoard"}
		@membership_lock.synchronize do
			return @objects[value] if key == :uuid
			return @objects.values.detect { |o| o.send(key) == value}
		end
	end
	def add(object)
		raise TypeError, "object must be an artifact" unless object.class.respond_to? :properties
		raise "Hoard cannot add a #{object.class.to_s} object because the uuid is invalid #{object.uuid}" unless Hoard.is_uuid?(object.uuid)

		@membership_lock.synchronize do
			existing = @objects[object.uuid]
			return existing unless existing.nil?

			__manage__(object)

			tmpdir = ".#{object.uuid}"
			if File.directory?(absolute_path(tmpdir))
				FileUtils::rm_rf(absolute_path(tmpdir))
			end
			mkdir(tmpdir)

			object.class.properties.each_key { |property|
				store_property(object, property, tmpdir)
			}
			open("#{tmpdir}/class", 'w') { |o|
				o.print object.class
			}

			rename(tmpdir, object.uuid)

			self.sync(object.uuid, 'class')
		end
		object
	rescue Exception => err
		logWarning {"Hoard add #{object.class} exception => #{err}"}
		raise
	end

	def manages?(object)
		manager = object.hoard
		return false if manager.nil?
		return false if @objects[object.uuid].nil?
		return true
	end

	def __manage__(object)
		return object if self.manages?(object)
		uuid = object.uuid
		object.instance_variable_set('@__hoard__', self)
		@objects[uuid] = object
	end

	def sync(dir, file=nil)
		name = @name
		dir = dir.chomp('/')
		path = "#{name}/#{dir}/#{file}"
		if (file == 'class')
			# logDebug { 'Syncer create' }
			Syncer.create(path)
		else
			# logDebug { 'Syncer add' }
			Syncer.add(path)
		end
	end

	def load_property(object, property)
		value, old_value = nil, nil
		filename = "#{object.uuid}/#{property}"
		path = absolute_path(filename)
		object.property_lock.synchronize {
			old_value = object.instance_variable_get("@#{property}")
			begin
				# object.instance_variable_set("__#{property}_timestamp__", Time.now)
				data = IO.read(absolute_path(filename))
				if data.length == 0
				elsif data.slice(0, 3) == '---'
					value = YAML.load(data)
				else
					value = data
				end
			rescue Exception => e
				logWarning {"Error loading hoard property #{property} on a #{object.class} object => #{e}"}
			end
			object.instance_variable_set("@#{property}", value)
		}
		[old_value, value]
	end

	def store_property(object, property, dir=nil)
		dir ||= object.uuid
		object.property_lock.synchronize {

			value = object.instance_variable_get("@#{property}")
			path = "#{dir}/#{property}"
			newfile = "#{dir}/#{property}.#{$UUID}"
			open(newfile, 'w') { |o|
				if object.class.properties[property.to_sym][:type] == :yaml
					YAML.dump(value, o)
				else
					o.write(value)
				end
				o.fsync
			}
			rename(newfile, path)
		}
	end

	def open(path, mode='r', &block)
		File.open(absolute_path(path), mode, &block)
	end

	def mkdir(subdir)
		path = File.join(@dir, subdir)
		# logDebug{ "mkdir #{path}" }
		Dir.mkdir(path)
	end

	def rename(oldpath, newpath)
		# logDebug{ "rename from #{oldpath} to #{newpath}" }
		File.rename(absolute_path(oldpath), absolute_path(newpath))
	end

	def absolute_path(path)
		File.join(@dir, path)
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
			Thread.current['hoard_refreshes'] = 1 + (Thread.current['hoard_refreshes'] || 0)
			old_value, value = object.send("#{property}_load")
		end
		object.instance_variable_get(property_instance_var)
	end

	def __skip_uuid_dir_of_trashed_object__(uuid)
		# TODO
		return false
	end
end
