module SuperNova
	class Dom
		def get_self
			puts self
		end
	end
	module Network
		class SharedNetwork
			class << self
				def get_name
					puts "self get name"
				end
			end
		end
		
	end
end

include SuperNova
# dom = Dom.new
# dom.get_self
SuperNova::Network::SharedNetwork.get_name
