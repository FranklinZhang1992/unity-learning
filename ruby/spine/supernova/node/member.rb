require 'hoard'
require 'supernova/node/errors'

module SuperNova
	class NodeMember
		artifact
		property :ordinal
		property :config_uuid
		property :pm_uuid
		property :kit_uuid
	end
	def log_title
		(hostname or uuid).to_s << "-member"
	rescue 'NodeMember'
	end
	def hostname
		"node#{ordinal || '???'}"
	end
	def initialize(uuid)
		uuid or raise "NodeMember.new() called with nil uuid value"
		@uuid = uuid
		self.ordinal = nil
	end
end
