# When parent thread is sleeping, its children will sleep, too. So we cannot keep the children threads keep running when their parent thread is dead.

require 'thread'
require 'webrick'
require 'rexml/document'
require 'securerandom'

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

class Stuff
  attr :uuid
  attr :name
  attr :active
  attr :count

  def initialize(name)
    @uuid = SecureRandom.uuid
    @name = name
    @active = false
    @count = 0
  end
  def enable
    @active = true
  end
  def disable
    @active = false
  end
  def write
    logNotice("[stuff] #{@count} name = #{@name}")
  end
end

class StuffService
  include Singleton
  include REXML
  def bootstrap
    @stuff_array = Array.new
    stuff1 = Stuff.new("stuff1")
    stuff2 = Stuff.new("stuff2")
    stuff3 = Stuff.new("stuff3")
    @stuff_array << stuff1
    @stuff_array << stuff2
    @stuff_array << stuff3
  end
  def each
    @stuff_array.each { |stuff| yield(stuff) }
  end
  def [](uuid)
    result = nil
    @stuff_array.each do |stuff|
      if stuff.uuid == uuid
        result = stuff
      end
    end
    result
  end
  def to_xml
    xml = Element.new('stuffs')
    @stuff_array.each do |stuff|
      stuff_xml = Element.new("stuff")
      stuff_xml << Element.new("id").add_text("#{stuff.uuid}")
      stuff_xml << Element.new("name").add_text("#{stuff.name}")
      xml << stuff_xml
    end
    xml
  end
end

def stuff_service() StuffService.instance end

class LogMachine
  include REXML
  attr :uuid
  def initialize
    @uuid = SecureRandom.uuid
    @log_thread_pool = Hash.new
    # @threads = ThreadGroup.new
  end

  def write_log_thread(stuff)
    stuff.write
    stuff.count += 1
    puts "current count is #{stuff.count}"
    if stuff.count == 10
      Thread.exit
    end
  end

  def show_thread_pool
    xml = Element.new('thread_pool')
    @log_thread_pool.each do |key, value|
      log_thread_xml = Element.new("#{key}").add_text("#{value}")
      xml << log_thread_xml
    end
    xml
  end

  def converge
    logNotice("converge...")
    stuff_service.each do |stuff|
      logNotice("stuff #{stuff.name} => active = #{stuff.active}")
      if stuff.active
        logNotice("thread[#{stuff.uuid}]: nil? => #{@log_thread_pool[stuff.uuid].nil?}")
        logNotice("thread[#{stuff.uuid}]: alive? => #{@log_thread_pool[stuff.uuid].alive?}") unless @log_thread_pool[stuff.uuid].nil?
        if @log_thread_pool[stuff.uuid].nil? || !@log_thread_pool[stuff.uuid].alive?
          log_thread = Thread.new {
            Thread.current['name'] = stuff.name
            loop {
              write_log_thread(stuff)
              sleep 2
            }
          }
          @log_thread_pool[stuff.uuid] = log_thread
        end
      end
    end
  end

end

class LogMachineService
  include Singleton
  def bootstrap
    @log_machine = LogMachine.new
    @log_machine_thread = Thread.new {
      loop {
        logNotice("log_machine is #{log_machine.uuid}")
        @log_machine.converge
        sleep 3
      }
    }
  end
  def interrupt
    @log_machine_thread.exit
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
    path = dispatch[1]
    begin
        result = ""
        case path
        when "all"
            result = stuff_service.to_xml
        when "enable"
          id = dispatch[2]
          result = stuff_service[id].enable
        when "disable"
          id = dispatch[2]
          result = stuff_service[id].disable
        when "show"
          result = log_machine_service.log_machine.show_thread_pool
        else
            result = "UNKNOWN"
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
  stuff_service.bootstrap
  log_machine_service.bootstrap
  trap("INT") {log_machine_service.interrupt; server.stop; }
  server.start
rescue Exception => e
  puts "Exception occur => #{e}"
end
