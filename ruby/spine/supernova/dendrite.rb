require 'singleton'
require 'thread'
require 'monitor'
require 'supernova/service'

module Dendrite
	class DendriteError < RuntimeError; end
	class BadDendriteMessage < DendriteError; end
	class Shutdown < ThreadError; end
	MAX_RECV_BYTES = 2400

	class Context
		def log_title
			:DendriteContext
		end
		attr_reader :id

		def initialize(message_id)
			@acknowledged = false
			@responded = false
			@responded_at = Time.at(0)
			@completed = false
			@completed_at = Time.at(0)
			@id = message_id
			@state = :start
		end
		def started?
			@thread != nil
		end
		def ignore
			logDebug {"ignoring repeated requrest #{id}"}
		end
		def complete
			@completed = true
			@completed_at = Time.now
		end
		def completion
			@completed_at
		end
		def completed?
			@completed
		end
		def failed?
			@exception != nil
		end
		def to_s
			"Context: #{id} #{@message[:service]}.#{@message[:method]}"
		end
		def acknowledged?
			@acknowledged
		end
		def process(message)
			logDebug {"process message => #{message}"}
			case
			when @thread.nil?; start_thread(message)
			when failed?; raise_remote(message)
			when @responded == false; acknowledge(message)
			when acknowledged?; complete
			when message.ack?; ignore
			else respond(message)
			end
		end
		def start_thread(message)
			logDebug {"start thread"}
			acknowledge(message)
			@thread = Thread.new { deliver(message) }
		end
		def deliver(message)
			logDebug {"delever [service_name : #{message.service}, method : #{message.method}, args : #{message.args}]"}
			service_name = message.service
			service = SuperNova::Service[service_name]
			puts "service is #{service}"
			if service.nil?
				logDebug {"No service named '#{service_name}"}
				SuperNova::Service.each {|s| logDebug {"Service: #{s.name}"}}
				return
			end
			method = message.method
			args = message.args
			logDebug {"handle #{id} as #{service_name}.#{method} args #{args}"}
			if service.respond_to?(method)
				@result = service.send(method, *args)
				logDebug {"#{service_name}.#{method} completed"}
			else
				raise NoMethodError.new("Dendrite method #{method} not supported by #{service_name}")
			end
			respond(message)

		rescue Exception => exception
			@exception = exception
			logWarning {"failed to process request: #{exception.class} => #{exception}"}
			raise_remote(message)
		end
		def raise_remote(message)
			result = {
				:node  => $UUID,
				:ident => message.ident,
				:exception => @exception.class.to_s
			}
			SuperNova.dendrite.transmit(message.address, message.port, Marshal.dump(result))
		end
		def respond(message)
			begin
				data = Marshal.dump(@result)
				if data.length > 1500
                    logWarning {"response larger than 1500 bytes [#{(data.dump)[0..25]} ...] -- setting to nil"}
                    @result = nil
				end
			rescue Exception => e
				logWarning {"Could not marshal response, changing to nil"}
				@result = nil
			end
			response = {
				:node => $UUID,
				:ident => message.ident,
				:result => @result
			}
			SuperNova.dendrite.transmit(message.address, message.port, Marshal.dump(response))
			@responded = true
			@responded_at = Time.now
		end
		def acknowledge(message)
			logDebug {"acknowledge [address => #{message.address}, port => #{message.port}]"}
			ack = {
				:node => $UUID,
				:ident => message.ident,
				:ack => true
			}
			# SuperNova.dendrite.transmit(message.address, message.port, Marshal.dump(ack))
		end
	end

	CONTEXTS = Hash.new { |hash, key| hash[key] = Context.new(key) }

	class Message
		def log_title
			:DendriteMessage
		end
		attr_reader :address, :port
		def initialize(request)
			data = request[0]
			@message = begin
				Marshal.load(data)
			rescue  Exception => exception
				logWarning {"decode failed: #{exception}"}
				raise BadDendriteMessage
			end
			@address = request[1][3]
			@port = request[1][1]
		end
		def ident
			@message[:ident]
		end
		def service
			@message[:service]
		end
		def method
			@message[:method]
		end
		def args
			@message[:args]
		end
		def ack?
			@message[:ack] = true
		end
		def id
			"#{@message[:node]}:#{@message[:ident]}"
		end
		def to_s
			"ID: #{id} #{@message[:service]}.#{@message[:method]}"
		end
	end

	class Service
		include Singleton
		def log_title
			'Dendrite'
		end
		def initialize
			@restarts = 0
			@socket = UDPSocket.open(Socket::AF_INET6)
			@socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
			@socket.bind('::', 8999)
			@handler = Hash.new
			@ignoring = false
		end
		def ignoring?
			@ignoring
		end
		def ignore!
			@ignoring = true
		end
		def transmit(address, port, data)
			@socket.send(data, 0, address, port)
		end
		def start
			logDebug { "Starting dendrite" }
			@thread = Thread.new do
				Thread.current['name'] = @title
				begin
					logNotice {"Waiting for events"}
					loop { do_one_event; cleanup }
				rescue Shutdown
					logNotice {"Closing socket"}
					@socket.close
				rescue Exception => exception
					logWarning {"Exception => #{exception}"}
					logInfo {"Restart: pausing before restart"}
					@restarts += 1
					sleep 2
					logInfo {"Restart (#{@restarts} times)"}
					retry
				end
				logNotice {"Thread exit"}
			end
		end
		def stop
			logNotice {"Stopping dendrite"}
			@thread.raise Shutdown
			begin
				@thread.join
			rescue Exception => exception
				logWarning {"Stop Dendrite failed => #{exception}"}
			end
			logNotice {"Dendrite stopped"}
		end
		def receive
			@socket.recvfrom(Dendrite::MAX_RECV_BYTES)
		end
		def do_one_event
			message = Message.new(receive)
			logDebug {"Get message => #{message}"}
			handler = CONTEXTS[message.id]
			return unless handler.started? if @ignoring
			handler.process(message)
		rescue BadDendriteMessage
			logWarning {"received bad message"}
		end
		def cleanup
			CONTEXTS.values.each do |context|
				next unless context.completed?
				next unless Time.now > (context.completion + 30)
				logDebug {"cleaning request #{context.id}"}
				CONTEXTS.delete context.id
			end
		end

	end
end

module SuperNova
	def self.dendrite
		Dendrite::Service.instance
	end
end
