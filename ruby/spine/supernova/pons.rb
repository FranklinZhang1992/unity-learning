require 'webrick'
require 'net/webdav'

module SuperNova
    def SuperNova.pons
        Pons::Service.instance
    end
    module Pons
        # curl http://localhost:8999/protected-virtual-machines/id/{uuid}/
        # curl -X POST -d 'test1' http://localhost:8999/protected-virtual-machines/id/{uuid}/
        class Domain < Net::WebDAV::Collection
            def initialize(server, *options)
                super(server, *options)
            end
            def get
                result = "Domain deal with get"
                return result
            end
            def post(body)
                logDebug('Pons') {"POST: request for domain => #{body}"}
                unless @controller.respond_to?(:rename)
                    logWarning('Pons') {"POST: invalie request"}
                    raise Net::WebDAV::BadRequest.new("invalie command rename")
                end

                data = @controller.send('rename', body)
            end
        end

        # curl -X PUT -d '' http://localhost:8999/protected-virtual-machines/
        class Domains < Net::WebDAV::Dictionary
            def initialize(server, filename, controller)
                super(server, filename, controller, Domain)
            end
            def get
                result = "Domains deal with get"
                return result
            end
            def put(body = '')
                logDebug('Pons') { "PUT: request for domains"}
                data = @controller.create
            end
        end

        class Root < Net::WebDAV::Collection
            def initialize(server, *options)
                super(server, "")
                @domains = add_view(Domains, 'protected-virtual-machines', SuperNova.domains)
            end
        end

        class Service < SuperNova::Service
            attr :root
            def bootstrap
                logDebug { "start up server" }
                config = { :Port => 8999,:DoNotListen => true}
                case
                when $debug == 0
                    logDebug('Pons') { "Send access log to /dev/null" }
                    config[:AccessLog] = [
                        [ File.open('/dev/null', 'w'),
                        WEBrick::AccessLog::COMMON_LOG_FORMAT]
                    ]
                    config[:Logger] = WEBrick::Log.new("#{$log_dir}/webrick.log")
                end

                @server = WEBrick::HTTPServer.new(config)
                @server.listen('::1', 8999)
                @server.listen('localhost', 8999)
                @server.listeners.each { |listener|
                    listener.setsockopt(Socket::SOL_SOCKET, Socket::SO_SNDBUF, (256*1024))
                }
                @root = Root.new(@server, "")
                @server.mount('/', @root)
                # @ready = true
                logDebug { "Pons booted" }
            end
            def ready?()
                @ready
            end
            def boot_thread
                @thread.join
            end
            def run
                begin
                    @server.start
                rescue Exception => exception
                    logWarning {"Pons started failed"}
                end
                logNotice {"Pons service finished, stopping"}
            end
            def stop
                @server.shutdown
                while @server.status != :Stop
                    logNotice {"Waiting to shundown webrick (#{@server.status})"}
                    sleep 1
                end
                @thread.exit
            end
        end
    end
end
