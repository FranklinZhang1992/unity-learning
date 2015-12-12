class PhantomService
	def initialize(name, manager)
		@name = name
		@manager = manager
		hostname = 'UNKNOWN'
		@title = "<#{hostname}:#{@name}>"
		@title
	end
end

class PhantomServices
	def initialize
		@services = Hash.new { |hash, key| 
			hash[key] = PhantomService.new(key, self)
		}
	end

	def [] (key)
		service = @services[key.to_s]
		service
	end
end

services = PhantomServices.new
puts "====================================================================="
p services
puts "====================================================================="
gateKeeperService = services['GateKeeper']
p gateKeeperService
puts "====================================================================="
