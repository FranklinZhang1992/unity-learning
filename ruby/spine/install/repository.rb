module Kernel
	def self.uuid
		IO.read('/proc/sys/kernel/random/uuid').strip
	end
end
