require 'singleton'

class ParentClass
	def initialize
		@children = []
		@views = Hash.new
		@views[:nodes] = NodeService.instance
	end
	def children
		@children + @views.values
	end
	def process(obj, view)
		obj.instance_variable_set('@view', view)
		def obj.children
			@controller.inject([]) do |list, child|
				resource = @view.new(child.id.to_s, child)
				list << resource
			end
		end
		p obj.children
	end
end

class Node

end

class NodeService
	include Singleton
	def [] (key)
		detect do |node|
			begin key = node.hostname || key = node.id
			rescue
				nil
			end
		end
	end
end

pc = ParentClass.new
pc.process(pc, NodeService.instance)