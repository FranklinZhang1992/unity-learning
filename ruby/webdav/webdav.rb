require 'webrick'

module Net
	module WebDAV
		class Resource < WEBrick::HTTPServlet::AbstractServlet
			def initialize(server, filename)
				@filename = filename
			end
			def name
				@filename
			end
			def parent=(collection)
				@parent = collection
			end
			def get_instance(server, *options)
				self
			end
			def path
				return @filename if @parent.nil?
				@parent.path + @filename
			end
			def do_GET(request, response)
				puts "Resource do get, request path = #{request.path}, filename = #{@filename}"
				begin
					if self.respond_to?(:get)
						data = get
						puts "data is #{data}"
						response.status = 200
						response.content_type = "text/plain"
						response.body = data
					end
				end
			end
		end

		class Collection < Resource
			def initialize(server, filename)
				super(server, filename)
				@views = Hash.new
				@children = []
			end
			def children
				@children + @views.values
			end
			def push_children(child)
				@children << child
			end
			def add_view(type, name)
				resource = type.new(@server, name)
				resource.parent = self
				@views[name] = resource
				resource
			end
			def add_collection(name)
				add_view(Collection, name)
			end
			def path
				return '/' if @parent.nil?
				@parent.path + @filename + '/'
			end
			def do_GET(request, response)
				puts "collection do get, request path = #{request.path}, filename = #{@filename}"
				segments = request.path.sub(path, '').split('/')
				lookup = segments.shift
				puts "current lookup is"
				p lookup
				puts "current views are"
				p @views.keys
				handler = @views[lookup]
				p handler
				if handler.nil?
					puts "Check for children"
					handler = children.detect { |child|
						puts "child.name is"
						p child.name
						child.name == lookup
					}
					p handler
				end
				begin
					handler.do_GET(request, response)
				rescue Exception => e
					p e
				end
			end
		end

		class Dictionary < Collection
			def initialize(server, filename, view=Resource)
				super(server, filename)
				@id = add_collection('id')
				@id.push_children(inject_resource('1', view))
				@id.push_children(inject_resource('2', view))
			end
			def inject_resource(id, view)
				resource = view.new(@server, id)
				resource.parent = self
				return resource
			end
		end
	end
end
