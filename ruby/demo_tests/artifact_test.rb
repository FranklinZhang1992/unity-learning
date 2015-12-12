class Module
	def artifact
		class << self
			def properties()
				const_get(:HoardProperties).clone
			rescue
				Hash.new 
			end	
		end

		def property(*symbols)
			symbols.each do |symbol|
				property_cfg(symbol)
			end
		end

		def property_cfg(symbol)
			define_method("#{symbol}=") { |value|
				puts "set value = #{value}"
			}
		end
	end
end

class Domain
	artifact
	property :name
	def set_name(name)
		self.send("name=", name)
	end
end

domain = Domain.new
domain.set_name("mike")