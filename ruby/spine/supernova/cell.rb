require 'hoard'
require 'supernova/service'
require 'supernova/node/member'
require 'supernova/node/config'
require 'base/extensions'

module SuperNova
    def self.gatekeeper
        GateKeeper.instance
    end
    def self.cell
        return @memoized_cell if @memoized_cell
        local_cell_uuid = SuperNova.nodes.config[$UUID].cell_uuid
        @memoized_cell = gatekeeper[local_cell_uuid]
    end
    class Cell
        artifact
        property :name
        property :address
        property :prefix
        property :gateway

        attr :members
        def initialize(config)
            @uuid = config[:cluster_uuid]
            self.class.properties.each_key { |prop|
                self.send("#{prop}=", config[prop])
            }
        end
        @@membership_lock = Monitor.new
        def load_hook
            @members = Hoard.new(self, "cells/#{self.uuid}/members", SuperNova::NodeMember)
        end
    end

    class CellInvitation
        attr :cell_uuid
        attr :node_ordinal
        def initialize(cell_uuid, node_ordinal)
            @cell_uuid = cell_uuid
            @node_ordinal = node_ordinal
        end
    end

    class GateKeeper < Service
        include Enumerable
        def each
            @hoard.each {|cell| yield cell}
        end
        def [](uuid)
            @hoard[uuid]
        end
        def bootstrap
            @hoard = Hoard.new(self, 'cells', Cell)
            if File.exists? SuperNova::SysConfig::FILENAME
                begin
                    # Create a Cell for an initial cluster install
                    config = SuperNova::SysConfig.new.read
                    logNotice {"creating a cell #{config.cluster_uuid} from the Unity install sysconfig file (#{SuperNova::SysConfig::FILENAME})"}
                    cell = @hoard[config.cluster_uuid]
                    unless cell
                        cell = Cell.new(config)
                        @hoard.add(cell)
                        cell.load_hook  # Hook should be called at add() time, but is not
                    end
                end
            end
        end
    end
end
