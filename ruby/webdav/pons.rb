require './webdav'
require './service'
require 'webrick'

module SuperNova
	def SuperNova.pons
		Pons::Service.instance
	end
	module Pons
		class Domain < Net::WebDAV::Resource
			def initialize(server, *options)
				super(server, *options)
			end
			def get
				result = "Domain deal with get"
				return result
			end
		end

		class Domains < Net::WebDAV::Dictionary
			def initialize(server, filename)
				super(server, filename, Domain)
			end
			def get
				result = "Domains deal with get"
				return result
			end
		end

		class Root < Net::WebDAV::Collection
			def initialize(server, *options)
				super(server, "")
				@domains = add_view(Domains, 'pvm')
			end
		end

		class Service < SuperNova::Service
			attr :root
			def bootstrap
				puts "start up server"
				config = { :Port => 8999,:DoNotListen => true}
				@server = WEBrick::HTTPServer.new(config)
				@server.listen('::1', 8999)
				@server.listen('localhost', 8999)
				@server.listeners.each { |listener|
					listener.setsockopt(Socket::SOL_SOCKET, Socket::SO_SNDBUF, (256*1024))
				}
				@root = Root.new(@server, "")
				@server.mount('/', @root)
				@ready = true
			end
			def ready?() @ready end
			def start
				if ready?
					@server.start
				end
			end
			def stop
				@server.shutdown
			end
		end
	end
end

