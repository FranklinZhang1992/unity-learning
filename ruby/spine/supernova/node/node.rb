require 'hoard'
require 'supernova/node/service'
require 'supernova/node/config'
require 'supernova/node/member'

module SuperNova
	class Node
		attr :pm_uuid

		def uuid
			member.uuid
		rescue
			nil
		end
		def id
			uuid
		end
		def node
			self
		end
		def config
			@config
		end
		def memory
			config.memory
		end
		def hostname
			(member || config).hostname
		rescue
			nil
		end
		def name
			hostname
		end
		def config_uuid
			config.uuid
		rescue
			nil
		end
		def cell_uuid
			config.uuid
		rescue
			nil
		end
		def version
			config.version
		rescue
			nil
		end
		def member
			return @member if @member
			@member = SuperNova.cell.members.detect {|m| m.config_uuid == config_uuid}
			if @member
				logNotice {"found membership object (#{@member.uuid}) for PM #{pm_uuid}"}
			end
			@member
		rescue
			nil
		end
		def member_state
			member.state
		rescue
			nil
		end
		def pm
			return config.pm if config && config.pm
			return member.pm if member && member.pm
			nil
		end
		def initialize(args={})
			@lock = Monitor.new
			@pm_uuid = args[:pm_uuid] || begin args[:member].pm_uuid rescue nil end
			return unless pm_uuid
			config_uuid = args[:config_uuid] || begin args[:member].config_uuid rescue nil end
			@config = SuperNova.nodes.config.detect {|config| config.uuid == config_uuid }
			if @config
				logInfo {"created a #{self.class} with hostname #{self.hostname} with NodeConfig"}
			end
			if !member and args[:member]
				@member = args[:member]  # Force to be the member() even though we don't know the 'pm_uuid' of this foreigner
			end
		end
		def hoard(controller, name, factory)
			logInfo {"created '#{name}' hoard for node #{config.uuid}"}
			Hoard.new(controller, "nodes/#{config.uuid}/#{name}", factory)
		end
		def address
			return config.private_v4 unless config.private_v4.nil?
			return hostname
		end
	end
end
