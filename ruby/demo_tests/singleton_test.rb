require 'singleton'

module SuperNova
	def SuperNova.ser() Service.instance end
	class Service
		include Singleton
		def change(param = "default")
			@singleParam = param
		end
		def display
			puts @singleParam
		end
	end
end

begin
include SuperNova
s1 = SuperNova.ser
s2 = SuperNova.ser

s1.change("max")
s1.display
s2.display
end