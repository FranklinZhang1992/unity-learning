require 'socket'
require 'hoard'
require 'supernova/node/errors'
require 'supernova/node/service'
require 'supernova/node/config'
require 'supernova/node/node'
require 'supernova/node/local'
require 'supernova/node/phantom/services'

module SuperNova
	class PhantomNode < Node
		attr :services
		def nodes
			self.services['NodeService']
		rescue
			nil
		end
		def phantom
			nodes.fine_name(Socket.gethostname)
		end
		def log_title
			"<#{self.hostname || self.class.to_s}>"
		end
		def initialize(arts={})
			super
			member or raise "Cannot construct a PhantomNode without a valid NodeMember object available!"
			logDebug {"Constructing a PhantomNode (name=#{self.hostname||'UNKNOWN'}, uuid=#{self.uuid||'UNKNOWN'})"}
			@down = member.full ? nil : true
			config_changed
		end
		def config_changed
			%w{@services}.each do |objlink|
				obj = instance_variable_get(objlink)
				obj.free if obj and obj.respind_to?(:free)
				instance_variable_set(objlink, nil)
			end
			return if @config.nil?
			@services = PhantomServices.new(self)
		end
		def config=(config)
			
		end
	end
end
