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

demo = Demo.new
puts demo.get("a")
