require 'hoard'
require 'supernova/cell'
require 'supernova/node/errors'
require 'supernova/node/service'

module SuperNova
    class LocalNode < Node
        def log_title
            self.hostname || self.class.to_s
        end
        def initialize(args={})
        end
        def accept_invitation(invitation)
            self.hostname = "node#{invitation.node_ordinal}"
            config.ordinal = invitation.node_ordinal
            config.cell_uuid = invitation.cell_uuid
        end
        def hostname=(val)
            logWarning {"not supported yet"}
        end
        def node0?
            return !self.hostname.match(/peer/)
        end
        def node1?
            return self.hostname.match(/peer/)
        end
        def in_a_cell?
            config.cell_uuid != nil
        end
    end
end
