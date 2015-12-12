require 'singleton'
require 'thread'
require 'monitor'

class HoardTransactionEntry
    attr :path
    def initialize(path)
        @path = path
    end
    def write
        File.open(transaction, 'a') { |o| o.puts @path}
    end
end

class HoardCreate < HoardTransactionEntry
    def transaction()
        "#{$SPOOL}/hoard/creates"
    end
end

class Syncer
    include Singleton
    def initialize
        @queue = {
            :create => Queue.new,
            :updattes => Queue.new,
            :deletes => Queue.new
        }
        @restarts = 0
        @ready = false
    end
    def ready?
        @ready
    end
    def self.create(path)
        Syncer.instance.enqueue_create(path)
    end
    def enqueue_create(path)
        @queue[:create].push(HoardCreate.new(path))
        @thread.wakeup
        nil
    end
    def process
        [:updates, :creates, :deletes].each do |type|
            queue = @queue[type]
            queue.pop.write until queue.empty?
        end
        Thread.stop
    end

    def start
        @thread = Thread.new do
            @ready = true
            begin
                loop {process}
            rescue Exception => exception
                p exception
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