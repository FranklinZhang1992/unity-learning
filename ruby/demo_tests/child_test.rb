# Only an example, cannot run

require 'webrick'

module SuperNova
	def SuperNova.nodeservie() Nodes.instance end

		class Collection < WEBrick::HTTPServlet::AbstractServlet
			def initialize(filename, controller)
				@filename = filename
				@controller = controller
			end

			def parent=(collection)
				@parent = collection
			end

			def add_collection(name, controller)
				add_view(Collection, name, controller)
			end

			def add_view(type, name, controller)
				resource = type.new(name, controller)
				resource.parent = self
				return resource
			end
		end

		class Dictionary < Collection
			def initialize(filename, controller, view)
				super(filename, controller)
				@id = add_collection('id', @controller)
				@id.instance_variable_set('@view', view)
				def @id.children
					@controller.inject([]) do |list, child|
						resource = @view.new(child.id.to_s, child)
						resource.parent = self
						list << resource
					end
				end
				p @id.children
			end
		end

		class Node
			def get_name
				puts "node"
			end
		end

		require 'singleton'

		class Nodes
			include Singleton
			include Enumerable

			def 

			def get_name
				puts "nodes"
			end
		end
end

include SuperNova

dic = Dictionary.new('nodes', SuperNova.nodeservie, Node)
