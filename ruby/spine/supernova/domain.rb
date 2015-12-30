require 'securerandom'
require 'hoard'
require 'supernova/domain/errors'

module SuperNova
    class Domain
        artifact

        property :name
        property :public_uuid
        property :vcpus
        def id
            public_uuid
        end
        def log_title
            title = self.name || 'Domain'
            title = "#{title}:#{my_thread}"
            title = "<#{title}>" unless local?
            title
        end
        def my_thread
            Thread.current.to_s[/[1-9][0-9a-f]+/]
        end
        def local?
            return true
        end
        def rename(newName = '')
            if newName.empty?
                return
            else
                self.send("name=", newName)
            end
        end
        # key-set => { :id, :name, :vcpus }
        def initialize(data)
            logDebug{"Initializing pvm"}

             @uuid = Kernel.uuid
             uuid = data[:id]
            if uuid
                self.public_uuid = uuid
            else
                self.public_uuid = Kernel.uuid
            end
            put_properties(data)
            load_hook
        end

        def init_hook
            @lock = Monitor.new
            @sync_port_lock = Monitor.new
            @ax_port_lock = Monitor.new
            @libguestfs_lock = Mutex.new
        end

        def load_hook
            logDebug {"TODO load hook"}
        end

        def put_properties(data, check_only = false)
            logDebug { "put properties" }
            properties = {
                :name =>  { :default => self.name || self.public_uuid, :convert => :to_s },
                :vcpus => { :default => self.vcpus || 1, :convert => :to_i}
            }
            vals = {}
            properties.each_pair { |prop, cfg|
                vals[prop] = (data[prop.to_s] || cfg[:default]).send(cfg[:convert])
            }

            # Check domain provisioning
            vals[:name].empty? and raise InvalidDomainConfig, "must specify a name or UUID for the VM"
            vals[:vcpus] >= 1 or raise InvalidDomainConfig, "VM cpu count is #{vals[:vcpus]}, must be at least 1"

            # Persist the changes
            vals.each_pair { |prop, val|
                self.send("#{prop}=", val) if self.respond_to?("#{prop}=")
            } unless check_only
            nil
        end

        def name_setter_hook(old, new)
            logInfo { "name setter hook old=#{old}, new=#{new}" }
        end

        def id_setter_hook(old, new)
            logInfo { "id setter hook old=#{old}, new=#{new}" }
        end

        def public_uuid_setter_hook(old, new)
            logInfo { "public uuid setter hook old=#{old}, new=#{new}" }
        end

        def name_load_hook(old, new)
            logInfo { "name load hook old=#{old}, new=#{new}" }
        end

        def to_s
            return "{ #{name}, #{public_uuid}, #{vcpus} }"
        end
    end
end
