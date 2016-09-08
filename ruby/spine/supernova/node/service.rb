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

        def config() @node_config_hoard end
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
            return if SuperNova.cell.nil?  # Only update peers once we're in a cluster
            @peers_lock.synchronize do
                logDebug {"checking node hoard for peer NodeConfig"}
                @node_config_hoard.each { |nodeconf|
                    next if nodeconf.uuid == $UUID
                    if nodeconf.locked and nodeconf.cell_uuid.nil?
                        logNotice {"Waiting to create phantom for peer node #{nodeconf.hostname} until the NodeConfig is unlocked or the node finishes installing"}
                        next
                    end
                    add_node_from_config(nodeconf)
                }
                SuperNova.cell.members.each { |m|
                    add_node_from_member(m)
                }
                self.peers_and_provisionals.each { |node| logNotice {"#{node.member_state||'non'} member node: #{node.hostname} (#{node.uuid})"} }
                update_ssh_authorization
                update_etc_hosts
                # Make sure the peer node is listed as an NTP time source
                set_ntp_servers(SuperNova.cluster.ntp_servers)
                update_domain_networks
            end
        end

        def add_node_from_config(node_config)
            if SuperNova.cell.nil?
                # Until we're in a cell, we can't know who the member nodes are, so we can't create a PhantomNode.
                logNotice {"add_node_from_config: skipping phantom create until this local node joins a cell/cluster"}
                return nil
            elsif node_config.cell_uuid and node_config.cell_uuid != SuperNova.cell.uuid
                logNotice {"add_node_from_config: ignoring node config from node in a foreign cell (#{node_config.uuid})"}
                return nil
            end
            member = SuperNova.cell.members.detect {|d| d.pm_uuid == node_config.pm_uuid}
            if member.nil?
                logNotice {"add_node_from_config: can't create a phantom for a non-member (#{node_config.hostname||node_config.uuid})"}
                return nil
            elsif member.creating? || member.deleting?
                logNotice {"add_node_from_config: skipping #{node_config.hostname||node_config.uuid}, member state \"#{member.state}\""}
                return nil
            end

            peer = nil
            @peers_lock.synchronize {
                peer = @peers.detect { |p| p.pm_uuid == node_config.pm_uuid }
                if peer
                    peer.config = node_config
                else
                    logNotice {"add_node_from_config: adding phantom for #{node_config.hostname} (#{node_config.uuid})"}
                    @peers.each { |p|
                        logNotice {"add_node_from_config:    existing phantom for #{p.hostname} (uuid=#{p.uuid}, object_id=#{p.object_id}, config_uuid=#{p.config_uuid})"}
                    }
                    if @peers.size > 0
                        logError {"add_node_from_config: about to add a THIRD node!!!!"}
                    end
                    begin
                        peer = PhantomNode.new(:pm_uuid => node_config.pm_uuid, :config_uuid => node_config.uuid)
                        @peers << peer
                    rescue => err
                        logException("add_node_from_config: failed to add a PhantomNode #{node_config.hostname} (uuid=#{node_config.uuid})", err)
                    end

                end
            }
            peer
        end
    end
end
