#!/usr/bin/ruby

require 'webrick'
require 'rexml/document'
require 'singleton'
require 'optparse'
require 'pathname'

$stdout.sync = true
$verbose = false

def log
    $logger ||= begin
        if $logfile
            dir = File.dirname($logfile)
            FileUtils.mkdir_p(dir)
            Logger.new($logfile)
        else
            Logger.new(STDOUT)
        end
    end
    $logger.level = $verbose ? Logger::DEBUG : Logger::INFO
    $logger
end

def trap_exit(server)
    ['HUP', 'QUIT', 'INT', 'TERM'].each do |signal|
        trap(signal) { server.stop }
    end
end

class Controller

    include Singleton

    def stop_influxdb
        # %x{systemctl stop influxdb}
        puts "stop influxdb"
    end
end

class PrepareResponse

    include REXML

    def self.build_response_body(status, msg)
        xml = Element.new('response')
        xml.attributes['status'] = status
        xml << Element.new('message').add_text(msg)
    end

    def self.ok(response)
        response.status = 200
        response['content-type'] = 'text/xml'
        response.body = build_response_body(response.status, "OK").to_s
    end

    def self.bad_request(response, error_msg)
        response.status = 400
        response['content-type'] = 'text/xml'
        response.body = build_response_body(response.status, error_msg).to_s
    end
end

class Root < WEBrick::HTTPServlet::AbstractServlet

    include REXML

    def initialize(server)
        super(server)
        @controller = Controller.instance
    end

    def get_instance(server, *options)
        self
    end

    def do_POST(request, response)
        log.debug("POST: body => #{request.body}")
        cmd = Document.new(request.body).root.name
        @controller.send(cmd)
        PrepareResponse.ok(response)
    rescue => err
        PrepareResponse.bad_request(response, "#{err}")
    end
end

class Server

    def initialize(options)
        log.debug("Initializing Server")
        config = {:Port => 9000, :BindAddress => '127.0.0.1'}
        @server = WEBrick::HTTPServer.new(config)
        @root = Root.new(@server)
        @server.mount('/', @root)
        File.open(options[:pidfile], 'w') {|o| o.print Process.pid.to_s ; o.fsync }
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

class CommandHandler
    include Singleton

    def initialize
        @options = {}
    end

    def parse(args)
        return if args.nil? || args.empty?

        opt_parser = OptionParser.new do |opts|
            opts.banner = "A server which can execute some commands"

            opts.on("-p", "--pidfile=PIDFILE", "Specified pid file") do |value|
                @options[:pidfile] = value
            end
            opts.on("-v", "--[no-]verbose", "Run verbosely") do |value|
                $verbose = value
            end
            opts.on("-l", "--log=LOG_FILE", "Print logs to file instead of STDOUT") do |value|
                $logfile = value
            end
        end

        opt_parser.order!
        @options
    end

    def handle(options)
        options = options.nil? ? {} : options
        server = Server.new(options)
        trap_exit(server)
        server.start
    end
end

if __FILE__ == $0
    begin
        options = CommandHandler.instance.parse(ARGV)
        CommandHandler.instance.handle(options)
    rescue SystemExit => err
        exit 0
    rescue Exception => err
        log.error("Server exited because error: #{err}")
        exit 1
    else
        exit 0
    end
end
