require 'hoard'
require 'supernova/node/errors'

module SuperNova
    class NodeConfig
        artifact
        property :hostname
        property :pm_uuid
        # property :cell_uuid
        # property :locked
        property :public_v6
        property :private_v6


        def log_title
            title = name or "node-#{uuid}" or 'NodeConfig'
            if uuid != $UUID
                foreign_node = begin
                    SuperNova.cell.uuid != cell_uuid
                rescue false
                end
                if foreign_node
                    title = "<foreign-#{title}>"
                else
                    title = "<#{title}>"
                end
            end
            title
        end
        def initialize(uuid)
            uuid or raise "NodeConfig.new called with nil uuid value"
            @uuid = uuid
            hn = self.hostname || 'UNKNOWN'
            logDebug {"new NodeConfig created for #{hn} #{self.uuid}"}
        end
    end
end
