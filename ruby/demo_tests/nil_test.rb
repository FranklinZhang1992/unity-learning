class Demo
  def initialize(config)
    @config = config
  end

  def output() @config['output'] end
  def output=(value) @config['output'] = value end
  def show
    shou_map = Hash.new
    shou_map['output'] = self.output.to_s unless self.output.nil?
    p shou_map
  end
end

begin
  config = Hash.new
  # config['output'] = 'abc'
  demo = Demo.new(config)
  demo.show
rescue Exception => e
  raise
end

