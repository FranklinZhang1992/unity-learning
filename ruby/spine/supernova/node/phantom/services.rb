require 'socket'
require 'supernova/service'
require 'supernova/node/errors'
require 'supernova/node/service'
require 'supernova/node/config'

module SuperNova
	class RemoteException < Exception
		attr_reader :remote
		def initialize(exception)
			super
			@remote = exception
		end
	end

	class PhantomService
		def log_title
			@title
		end
		def initialize(name, manager)
			@name = name
			@manager = manager
			@public = nil
			@private = nil
			hostname = @manager.config.nil? ? 'UNKNOWN' : @manager.config.hostname.to_s
			@title = "<#{hostname}:#{@name}>"
			logDebug {"create service client for #{@title}"}
			@title
		end
		def free
			@manager = nil
		end
		def call_remote_method(symbol, *args)
			serial = Time.now.to_f
			state = :start
			result = nil
			remote_exception = nil
			unless @manager.node_up?
				logDebug {"NODE IS DOWN -- do not send message"}
				raise NodeUnreachable.new(@manager.config.hostname)
			end
			message = {
				:node => $UUID,
				:ident => serial,
				:service => @name,
				:method => symbol,
				:args => args
			}
			socket = UDPSocket.new(Socket::AF_INET6)
			config = @manager.config
			sent = false
			[config.private_v6, config.public_v6].each { |address|
				next if address.nil?
				begin
					sent_size = socket.send(Marshal.dump(message), 0, address, 8999)
					logError {"Exceeded dendrite receive limit (#{sent_size} > #{Dendrite::MAX_RECV_BYTES})"} if sent_size > Dendrite::MAX_RECV_BYTES
					sent = true
				rescue Exception => exception
					logWarning {"Call remote method failed => #{exception}"}
				end
			}
			raise NodeUnreachable.new(@manager.config.hostname) unless sent

			thread = Thread.new {
				loop do
					data = socket.recvfrom(1500)
					response = Marshal.load(data[0])
					case
					when response.has_key?(:exception)
						logDebug {"#{response[:exception]} exception excuting remote method"}
						remote_exception = begin
							typename = response[:exception]
							typename.split('::').inject(Module)
						rescue Exception => e
							RuntimeError
						end
						state = :exception
						break
					when response.has_key?(:result)
						if state != :ack
							logDebug {"#{serial} -- missed ack, got result"}
						end
						state = :result
						result = response[:result]
						message[:ack] = true
						[config.private_v6, config.public_v6].each { |address|
							Kernel.ignore("dendrite response dropped on #{address}") {
								socket.send(Marshal.dump(message, 0, address, 8999))
							}
						}
						break
					when response.has_key?(:ack)
						state = :ack
					else
						logError {"Invalid dendrite message '#{response}"}
					end
				end
			}

			elapsed = 0
			timeout = 15
			until thread.join(3)
				elapsed += 3
				timeout = 40 if state != :start
				if elapsed > timeout
					case state
					when :start; logError {"#{serial} -- message never acked"}
					when :repond; logError {"#{serial} -- message timed out responding"}
					else logWarning {"#{serial} -- message failed"}
					end
					thread.kill
					break
				end
				unless @manager.node_up?
					logDebug {"NODE went down"}
					thread.kill
					break
				end
				logDebug {"retry: #{serial}"}
				[config.private_v6, config.public_v6].each { |address|
					Kernel.ignore("dendrite retrans dropped on #{address}") {
						socket.send(Marshal.dump(message, 0, address, 8999))
					}
				}
			end
			socket.close
			case state
			when :exception; raise RemoteException.new(remote_exception)
			when :result; result
			when :ack;
				logDebug {"Dendrite call (#{symbol}) acked, but response time out"}
				raise NodeUnreachable.new(@manager.config.hostname)
			else
				logDebug {"Dendrite call (#{symbol}) resulted in an unexpected state #{state}"}
				raise NodeUnreachable.new(@manager.config.hostname)
			end
		rescue NodeUnreachable; raise
		rescue RemoteException => exception
			raise exception.remote
		rescue Exception => exception
			logWarning {"#{serial} -- #{symbol} => #{exception}"}
			raise
		end

		alias :method_missing :call_remote_method
	end

	class PhantomServices
		attr_reader :config
		def log_title
			:PhantomServices
		end
		def initialize(node_or_config)
			@node = node_or_config
			@config = @node.respond_to?(:config) ? @node.config : @node
			@services = Hash.new { |hash, key| 
				hash[key] = PhantomService.new(key, self)
			}
		end	
		def free
			@services.values.each {|svc| svc.free}
			@services = @config = @node = nil
		end
		def [](key)
			service = @services[key.to_s]
			service
		end
		def node_up?
			@node.respond_to?(:spine_up?) ? @node.spine_up? : true
		end
	end
end
