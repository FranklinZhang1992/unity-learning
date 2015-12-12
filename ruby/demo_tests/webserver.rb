require "webrick"
require "./server"

class Root < MyServlet

	def initialize(server, *options)
		super(server)
	end
	def get
		@param
	end
end

class Service
	
	def bootstrap
		config = { :Port => 8999,:DoNotListen => true}
		@server = WEBrick::HTTPServer.new(config)
		@server.listen('::1', 8999)
		@server.listen('localhost', 8999)
		@server.listeners.each {|listener|
			listener.setsockopt(Socket::SOL_SOCKET, Socket::SO_SNDBUF, (256*124))
		}
		# priv_listen()
		@root = Root.new(@server, "")
		@server.mount("/", @root)
	end
	def priv_listen()

	end
	def boot_thread
		@thread.join
	end
	def run()
		# begin
		# trap("INT") {@server.shutdown}
		@thread = Thread.new do 
			@server.start
			# puts "in the thread"
		end
			
		# rescue Exception => Exception
		# 	puts "error occur"
		# end
	end
	def stop
		@server.shutdown
	end

end

service = Service.new
service.bootstrap
trap("INT") {service.stop}
puts "service will run"
service.run
service.boot_thread
