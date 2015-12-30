module SuperNova
    class NodeException < RuntimeError
        attr :nodename
        def initialize(nodename)
            @nodename = nodename
        end
    end
    # < NodeException ???
    class NodeUnreachable < RuntimeError
        def initialize(nodename)
            super(nodename)
        end
    end
end
