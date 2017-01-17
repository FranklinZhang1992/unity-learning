class Demo
  define_method(:name) { puts "name" }
  ["aaa", "bbb", "ccc"].each do |name|
    define_method("test_#{name}") { |param| puts "test #{param}" }
  end
end

begin
  demo = Demo.new
  demo.test_aaa("aaa")
rescue Exception => e
  raise
end
