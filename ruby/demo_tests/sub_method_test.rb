class Collection
	def initialize
		@children = ""
	end
	def children
		@children
	end
end

class Dictionary < Collection
	def initialize
		@id = Collection.new
		def @id.children
			puts "children"
		end
	end
	def get_id_children
		@id.children
	end
end

dic = Dictionary.new
dic.get_id_children
dic.get_id_children
dic.get_id_children