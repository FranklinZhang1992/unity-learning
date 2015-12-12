require 'singleton'

class Collection
	def initialize(controller)
		# puts "initialize Collection, controller=#{controller}"
		@controller = controller
		@children = []
		@views = Hash.new
	end

	def children
		@children + @views.values
	end

	def add_collection(name, controller)
		resource = Collection.new(controller)
		# puts "new resource, output"
		# p resource
		@views[name] = resource
		resource
	end
end

class Dictionary < Collection
	def initialize(controller, view)
		# puts "initialize Dictionary, controller=#{controller}, view=#{view}"
		super(controller)
		@id = add_collection('id', @controller)
		# puts "output @id"
		# p @id
		# puts "output view"
		# p view
		@id.instance_variable_set('@view', view)
		# puts "output @view"
		# p @id.instance_variable_get('@view')
		# puts "before: output children"
		# p @id.children
		# puts "out put @controller"
		# p @controller
		def @id.children
			@controller.inject([]) do |list, child|
				puts "before: inject list=#{list}, child=#{child}"
				resource = @view.new(child)
				p resource
				list << resource
				puts "after: inject list=#{list}, child=#{child}"
			end
		end
		# puts "after: output children"
		# p @id.children
	end
end

class Service
	include Singleton
	@@services = Array.new
	def self.[](key)
		@@services.detect { |service| service.name == key}
	end

	def self.each()
		@@services.each { |service| yield service}
	end

	def get_services
		@@services
	end

	def initialize
		# puts "initialize Service"
		@@services << self
		# p @@services
	end

	def boot
		bootstrap
	end

	def bootstrap
	end
end

class DomainService < Service
	def every
		@hoard.each { |domain| yield(domain) }
		rescue []
	end
	def each
		@hoard.each { |domain| yield(domain) }
	end
	include Enumerable
	def [](uuid)
		@hoard[uuid]
	end

	def bootstrap
		@hoard = Hoard.new
		@booted = true
	end
end


class NodeService < Service
	def every
		@hoard.each { |domain| yield(domain) }
		rescue []
	end
	def each
		@hoard.each { |domain| yield(domain) }
	end
	include Enumerable
	def [](uuid)
		@hoard[uuid]
	end

	def bootstrap
		@hoard = Hoard.new
		@booted = true
	end
end

class Domain < Collection
	def initialize(controller)
		super(controller)
	end
end

class Domains < Dictionary
	def initialize(controller)
		super(controller, Domain)
	end
end

class Node < Collection
	def initialize(controller)
		super(controller)
	end
end

class Nodes < Dictionary
	def initialize(controller)
		super(controller, Node)
	end
end

class Hoard
	def initialize
		@objects = Hash.new
		@objects[1] = 'domain'
		@objects[2] = 'domain2'
	end
	def values
		@objects.values
	end
	def each
		values.each { |d| yield d }
	end
	def [] (value, key=:uuid)
		# puts "output @objects"
		return @objects[value]
	end
end

def init_domains
	DomainService.instance
end

def init_nodes
	NodeService.instance
end

# Test begin
init_domains.boot
init_nodes.boot

domains = Domains.new(init_domains)
puts "get children"
p domains.children



# temp = [1, 2]
# p temp
# p temp.inject { |result, element|
# 	puts "test"
# 	result + element

# }
# p temp