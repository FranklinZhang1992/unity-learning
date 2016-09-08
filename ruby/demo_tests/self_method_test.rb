class Demo
  def self.test
    puts "self.test"
  end
  def test
    puts "test"
  end
  def Demo.test
    puts "Demo.test"
  end
  def send1
    Demo.test
  end
  def send2
    self.test
  end
  def send3
    test
  end
end

demo = Demo.new
demo.send1
demo.send2
demo.send3
Demo.test
demo.test
