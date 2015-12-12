class DemoService
	include Enumerable
	def initialize
		@objects = Hash.new
		@objects[1] = "domain1"
		@objects[2] = "domain2"
	end
	def each
		@objects.values.each { |d| yield d }
	end
	def []
		return @objects.values
	end
end

demo = DemoService.new
demo.inject([]) { |list, child|
	puts "before"
	p list
	p child
}