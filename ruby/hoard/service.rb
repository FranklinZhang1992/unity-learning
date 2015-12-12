require 'singleton'
require './domain'
require './hoard'

module SuperNova
	def SuperNova.domains()
		DomainService.instance
	end

	class Service
		include Singleton

		def booted?()
			@booted
		end

		def boot
			bootstrap
		end

		def bootstrap() end
	end 

	class DomainService < Service
		attr_reader :hoard
		def bootstrap
			@hoard = Hoard.new(self, 'protected-virtual-machines', Domain)
		end
		def create
			@domain = Domain.new('test-machine', 123456)
		end

		def update(name, id)
			@domain.put_properties(name, id)
		end
	end
end