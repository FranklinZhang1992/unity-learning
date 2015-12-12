require 'singleton'
require 'thread'

class Syncer
	include Singleton

	def initialize
		@restarts = 0
		@ready = false
	end
	def ready?
		@ready
	end
	def process
		# [:updates, :creates, :deletes].each do |type|
		# 	queue = @queue[type]
		# 	queue.pop.
		# end
		# Thread.stop
		puts "processing"
		Thread.stop
	end
	def self.create
		puts "create added"
		Syncer.instance.enqueue_create
	end
	def enqueue_create
		@thread.wakeup
		nil
	end
	def start
		@thread = Thread.new do
			Thread.current['name'] = 'Syncer'
			@ready = true
			begin
				loop { process }
			rescue
				puts "service died"
				puts "restart service"
				@restarts += 1
				sleep 2
				retry
			end
		end
		sleep(1) until ready?
	end
	def stop
		@thread.exit
	end

end

Syncer.instance.start