require 'singleton'
require 'securerandom'

module SuperNova
	
	class Service
		include Singleton
		@@services = Array.new
		attr :sleeptime, true
		attr :restarts
		attr :name
		def self.[] (key)
			@@services.detect { |service| service.name == key }
		end
		def self.each
			@@services.each { |service| yield service }
		end
		def initialize
			@queue = Queue.new
			@name = @title = self.class.to_s.sub(/^SuperNova::/, '').sub(/::Service$/, '')
			@sleeptime = 3
			@messagelimit = 5
			@ready = false
			@handlers = Hash.new
			@loaded = false
			@restarts = 0
			@threads = ThreadGroup.new
			@@services << self
		end
		def booted?()
			@booted
		end

		def boot
			return if booted?
			begin
				logInfo {"BootStrap"}
				start_time = Time.now
				bootstrap
				elapsed = Time.now - start_time
				if elapsed > 10
					logWarning {"BootStrap took #{elapsed} seconds"}
				else
					logNotice {"BootStrap complete"}
				end
			rescue Exception => exception
				die('bootstrap', exception)
			end
			@booted = true
		end

		def bootstrap() 
		end

		def ready?
			@ready
		end

		def alive?
			@thread.nil? ? false : @thread.alive?
		end

		def warn(phase, exception)
			svc_name = (@thread.nil? ? 'UNKNOWN' : (@thread['name'] || 'UNKNOWN'))
			logError {"===================================================="}
			logError(svc_name) {"Service died: phase [#{phase}], with exception #{exception}"}
			exception.backtrace.each { |line| logError {" => #{line}"} }
			logError {"===================================================="}
		end

		def die(phase, exception)
			warn(phase, exception)
			Kernel.exit
		end

		def start
			@thread = Thread.new do
				Thread.current['name'] = @title
				Thread.current['service'] = self
				boot unless booted?
				begin
					logDebug { "Starting" }
					@ready = true
					run
				rescue Exception => exception
					@restarts += 1
					sleep 5
					logInfo { "Restart (#{@restarts} times)" }
					retry
				end
			end
			sleep(1) until ready? unless ready?
			logInfo { "Ready" }
		end

		def run
			logInfo {"TODO: run method"}
			# while true
			# 	svc_name = Thread.current['name']

			# end
		end

		def shutdown
			logNotice {"Shutdown service"}
		end

		def stop
			shutdown
			@threads.list.each { |thread|
				logNotice {"Stop: #{thread['name']} helper"}
				thread.exit
			}
			if @thread
				svc_name = @thread['name'] || 'UNKNOWN'
				@thread.exit
				@thread.join
				@thread = nil
			end
			logNotice {"Stop: shutdown"}
		end
	end
end

$service = SuperNova::Service
