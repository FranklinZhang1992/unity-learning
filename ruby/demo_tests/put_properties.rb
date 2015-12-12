require 'rexml/document'

class Domain
	attr :name
	attr :memory
	attr :vcpus
	def initialize(name, memory, vcpus)
		@name = name
		@memory = memory
		@vcpus = vcpus
		@public_uuid = 11111
	end
	def put_properties(xml)
		properties = {
			:name   => { :default => self.name || self.public_uuid, :convert => :to_s},
			:memory => { :default => self.memory || 256, :convert => :to_i},
			:vcpus  => { :default => self.vcpus || 1, :convert => :to_i}
		}
		empty = REXML::Element.new
		vals = {}
		properties.each_pair { |prop, cfg|
			vals[prop] = ((xml.elements[prop.to_s]||empty).text || cfg[:default]).send(cfg[:convert])
		}
		p vals
		vals.each_pair { |prop, val|
			puts "#{prop}="
		}
	end
end

xml = REXML::Document.new
dom = Domain.new('name1', '5', 2)
dom.put_properties(xml)