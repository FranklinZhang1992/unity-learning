class RespondDemo
	def put(body)
		puts "put"
	end
end

begin
	r = RespondDemo.new
	p r.respond_to? :put
	p r.nil?
end