class Domain
	property :name
	property :id
	def initialize(name, id)
		@name = name
		@id = id
	end

	def property(*symbols)
		symbols.each do |symbol|
			
		end
	end
end

dom = Domain.new('test', 123)
p dom.class
