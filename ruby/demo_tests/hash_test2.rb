class Demo
    def initialize
        @group = Hash.new
        @group["a"] = "aaa"
        @group["b"] = "bbb"
    end
    def get(key)
        return @group[key]
    end
end

class Demo2
    def initialize
        @ha = Hash.new
        @ha[:a] = lambda { |var|
            puts "a#{var}"
        }
        @ha[:b] = lambda { |var|
            puts "b#{var}"
        }
    end

    def handle(key)
        handler = @ha[key]
        raise "no handler" if handler.nil?
        handler.call("test")
    end
end

# demo = Demo.new
# puts demo.get("a")
demo2 = Demo2.new
demo2.handle('a')
demo2.handle('b')
