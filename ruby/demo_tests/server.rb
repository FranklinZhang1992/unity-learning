require "webrick"

class MyServlet < WEBrick::HTTPServlet::AbstractServlet

	def initialize(server)
		super(server)
	end
	def do_GET(request, response)
		response.status = 200
		response.content_type = "text/plain"
		response.body = "Hello, world!"
	end
	def do_POST(request, response)
		puts "post"
	end
end

# server = WEBrick::HTTPServer.new(:Port => 8188)
# server.mount("/test", MyServlet)
# trap("INT") {server.shutdown}
# server.start

# myservlet = MyServlet.new(server)
# puts myservlet.respond_to? :do_GET
# puts myservlet.respond_to? :do_POST
# puts myservlet.respond_to? :do_PUT
# puts myservlet.respond_to? :do_DELETE