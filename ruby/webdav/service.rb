require 'singleton'

module SuperNova
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
end