class C1

end

class C2 < C1
	def add_resource(type)
		resource = type.new
		p resource.parent
		resource.parent = self
		p resource.parent
	end
	def parent
		@parent
	end
	def parent=(co)
		@parent = co
	end
end

c = C2.new
c.add_resource(C2)