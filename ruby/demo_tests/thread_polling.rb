require 'thread'
require 'webrick'
require 'rexml/document'

LOG_FILE = "../logs/thread_polling.log"
$COUNT = 0


def current_thread() Thread.current.to_s[/[1-9][0-9a-f]+/] end
def current_time() Time.now.strftime("%d/%m %X") end

def log(level, message)
  File.open(LOG_FILE, 'a') do |io|
    io.puts "[#{level}] #{current_time} [#{current_thread}] #{message}"
  end
end

def logNotice(message)
  log("INFO", message)
end

class LogMachine
  def initialize
    @log_thread = nil
  end

  def on_event(signal)
    result = signal
    @log_thread.nil? or logNotice("[1] current thread status is #{@log_thread.status}")
    begin
      case signal
      when 'start'
        if @log_thread.nil?
          logNotice("thread is nil, will create a new thread")
          @log_thread = Thread.new { loop { write_log_thread; sleep 2 } }
        elsif !@log_thread.alive?
          logNotice("thread is #{@log_thread.status}, will create another thread")
          @log_thread = Thread.new { loop { write_log_thread; sleep 2 } }
        end
      when 'stop'
        @log_thread.nil? or @log_thread.exit
      when 'int'
        @log_thread.nil? or @log_thread.exit
      end
    rescue Exception => e
      result = "#{e}"
    end
    @log_thread.nil? or logNotice("[2] current thread status is #{@log_thread.status}")
    result
  end

  def write_log_thread
    $COUNT += 1
    logNotice("This is a log from LogMachine (#{$COUNT})");
    if $COUNT == 5
      Thread.exit
      @log_thread = nil
    end
  end
end

class LogMachineService
  include Singleton
  def bootstrap
    @log_machine = LogMachine.new
  end
  def interrupt
    %x{rm -rf #{LOG_FILE}}
  end
  def log_machine() @log_machine end
end

def log_machine_service() LogMachineService.instance end

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
        result = ""
        case path
        when "start"
            result = log_machine_service.log_machine.on_event("start")
        when "stop"
            result = log_machine_service.log_machine.on_event("stop")
        when "int"
            result = log_machine_service.log_machine.on_event("int")
        else
            result = "UNKNOWD"
        end
        parse_response(response, result)
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
end

class Server
  def bootstrap
    puts "start up server"
    config = { :Port => 9527,:DoNotListen => true }
    @server = WEBrick::HTTPServer.new(config)
    @server.listen('::1', 9527)
    @server.listen('localhost', 9527)
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

begin
  server = Server.new
  server.bootstrap
  log_machine_service.bootstrap
  trap("INT") {log_machine_service.interrupt; server.stop; }
  server.start
rescue Exception => e
  puts "Exception occur => #{e}"
end
