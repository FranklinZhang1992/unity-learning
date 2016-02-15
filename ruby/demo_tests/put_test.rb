class Demo
  attr :name

  def initialize(name)
    @name = name
  end
end

demo = Demo.new("test")
puts "puts demo = ", demo
p "p demo = ", demo
