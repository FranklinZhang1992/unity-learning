require 'hoard'
require 'supernova/service'

module SuperNova
    def SuperNova.domains
        DomainService.instance
    end
    class DomainService < Service
        include Enumerable
        attr_reader :hoard
        def every
            logDebug {"call method every in DomainService"}
            @hoard.each { |domain| yield(domain) } rescue []
        end
        def each
            logDebug {"call method each in DomainService"}
            @hoard.each { |domain| yield(domain) }
        end
        def [](uuid)
            logDebug {"call method [] in DomainService"}
            @hoard[uuid] or @hoard[uuid, :public_uuid]
        end
        def bootstrap
            @booted = false
            @hoard = Hoard.new(self, 'pvm', Domain)
            @booted = true
            logDebug { "DomainService booted" }
        end
        def booted?
            @booted
        end
        def create
            logDebug { "Start create Domain" }
            begin
                data = Hash.new
                id = SecureRandom.uuid
                data["id"] = id
                suffix = id[0, 8]
                data["name"] = "test-#{suffix}"
                data["vcpus"] = 1
                domain = Domain.new(data)
                old = self.detect { |old| old.name == domain.name }
                @hoard.add(domain)
                logDebug { "Domain created successfully" }
            rescue Exception => exception
                logWarning { "Create Domain failed => #{exception}" }
            end
            return domain.to_s
        end
    end

end
