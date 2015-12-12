require 'singleton'
module SuperNova
	def SuperNova.vms() LocalService.instance end
	class LocalService
		include Singleton
		def boot
			puts "boot"
		end
	end
end

begin
	include SuperNova
	SuperNova.vms.boot
end