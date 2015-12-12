require 'securerandom'
class Hoard
	@@uuid_regexp = /^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$/
	def Hoard.is_uuid?(str)
		return @@uuid_regexp.match(str)
	end
end

hoard = Hoard.new
str = SecureRandom.uuid
p str
p Hoard.is_uuid?(str)