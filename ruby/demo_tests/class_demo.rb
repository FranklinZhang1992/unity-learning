module ClassDemo
	class HelloWorld
		attr_accessor :name

		def initialize(myname = "Ruby")
			@name = myname
		end
		def test_name
			name = "Ruby"
			self. name = "Ruby2"
		end
	end
end
