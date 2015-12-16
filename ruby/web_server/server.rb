require 'webrick'
require 'rexml/document'


class ClientError < StandardError
    def initialize(body=nil, type='text/xml')
        @body = body
        @type = type
    end
    def body
        case
        when @body.is_a?(String) ;
            error = Element.new('error')
            error << Element.new('message').add_text(@body)
            Build.document(error).to_s
        when @body.is_a?(Document) ; @body.to_s
        when @body.is_a?(Element)  ; Build.document(@body).to_s
        else @body
        end
    end
    def prepare(response)
        response.status = @status
        response['content-type'] = @type
        response.body = self.body.to_s
    end
end

class Root < WEBrick::HTTPServlet::AbstractServlet
    include REXML
    def initialize(server)
        super(server)
    end
    def get_instance(server, *options)
        self
    end
    def do_GET(request, response)
        puts "Resource do get, request path = #{request.path}"
        dispatch = request.path.split('/')
        path = dispatch[dispatch.length - 1]
        begin
            data = ""
            case path
            when "watch"
                data = get_all
            when "network"
                data = get_networks
            when "host"
                data = get_hosts
            else
                data = get_all
            end
            parse_response(response, data)
        rescue ClientError => exception
            exception.prepare(response)
        end
    end
    def parse_response (response, xml = nil)
        response.status = 200
        response['content-type'] = 'text/xml'
        return if xml.nil?
        response.body = xml.to_s
    end
    def get_all
        puts "=> all"
        xml_path = "mock/response.xml";
        doc = Document.new(File.open(xml_path))
    end
    def get_networks
        puts "=> network"
        xml_path = "mock/response_network.xml"
        doc = Document.new(File.open(xml_path))
    end
    def get_hosts
        puts "=> hosts"
        xml_path = "response_host.xml"
        doc = Document.new(File.open(xml_path))
    end
end

class Server
    def bootstrap
        puts "start up server"
        config = { :Port => 8999,:DoNotListen => true }
        @server = WEBrick::HTTPServer.new(config)
        @server.listen('::1', 8999)
        @server.listen('localhost', 8999)
        @root = Root.new(@server)
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

server = Server.new
server.bootstrap
trap("INT") {server.stop}
server.start