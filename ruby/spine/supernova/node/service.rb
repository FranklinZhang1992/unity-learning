require 'monitor'
require 'hoard'
require 'supernova/service'
require 'supernova/domain'
require 'supernova/node/errors'
require 'supernova/node/config'

module SuperNova
    def SuperNova.nodes
        NodeService.instance
    end
    def SuperNova.node
        NodeService.instance.local
    end

    class NodeService < Service
        include Enumerable
        attr :local
        def bootstrap
            @priv0_lock = Monitor.new
            @biz0_lock = Monitor.new
            @peers_lock = Monitor.new
            @peers = []
            @node_config_hoard = Hoard.new(self, 'nodes', NodeConfig)
            @node_config_hoard.each { |object|
                logDebug {"NodeHoard: loaded #{object.hostname}"}
            }
            node_config = @node_config_hoard[$UUID]
            if node_config.nil?
                logWarning {"no local node info found in hoard, creating..."}
                node_config = NodeConfig.new($UUID)
            end
            logNotice {"Initialize local node"}
            @local = LocalNode.new
            update_peers
            logDebug { "NodeService booted" }
        end
        def update_peers
        end
    end
end
