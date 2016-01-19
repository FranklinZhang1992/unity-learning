class Demo
  def self.test(par1, par2)
    puts "self.test"
  end
  def test(par1)
    puts "test"
  end
  def send1
    Demo.test("a", "b")
  end
  def send2
    self.test("a", "b")
  end
  def send3
    test("a")
  end
end

demo = Demo.new
demo.send1
demo.send2
demo.send3
