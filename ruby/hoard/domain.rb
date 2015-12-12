require './hoard'

module SuperNova
	class Domain
		artifact

		property :name
		property :id

		def initialize(name, id)
			put_properties(name, id)
		end

		def put_properties(name, id)
			puts "put properties #{name} and #{id}"
			self.send("name=", name)
			self.send("id=", id)
		end

		def name_setter_hook(old, new)
			puts "name setter hook old=#{old}, new=#{new}"
		end

		def id_setter_hook(old, new)
			puts "id setter hook old=#{old}, new=#{new}"
		end
	end
end