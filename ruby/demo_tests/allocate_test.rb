class Demo
    attr :name
    def initialize(name)
        @name = name
    end
end

demo1 = Demo.new("demo1")
puts "demo1: #{demo1.name}"

demo2 = Demo.allocate
puts "demo2: #{demo2.name}"
