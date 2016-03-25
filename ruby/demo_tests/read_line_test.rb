#!/usr/bin/ruby

require 'readline'
require 'net/http'
require 'uri'
require 'rexml/document'

include REXML

class String
  def to_bool
    return true if self =~ (/^(true|t|yes|y|1)$/i)
    return false if self.empty? || self =~ (/^(false|f|no|n|0)$/i)

    raise ArgumentError.new "invalid value: #{self}"
  end
end

class Commands
  WIN_2K12_REGEXP = 'win\S*2[0-9a-zA-Z]{0,}12'
  def help
    msg = "read_line:\n"
    msg += "<command> [args...]\n"
    msg += "duts <mode>                            list all DUTs(optional mode values are: all, idle, reserved)\n"
    msg += "vcd <name> <count> <scope>             search for a DUT contains specified VCD, if input name is in [win2k12], then will use regexp, otherwise just search the full match name, valie scope values are [all, idle, reserved], count means how many such DUT you want to find.\n"
    msg += "quit                                  exit\n\n"
    puts msg
  end
  def fetch_duts(mode="all")
    raise "unknown mode #{mode}" unless mode == "all" || mode == "idle" || mode == "reserved"
    data = nil
    duts = []
    Net::HTTP.start('134.111.24.33', 80) do |http|
      response = http.get('/')
      raise "Cannot talk to rinfo" unless response.code.to_i == 200
      data = response.body
    end
    data = data.gsub('target=_blank', 'target="_blank"')
    data = data.gsub('class=reserved', 'class="reserved"')
    data = data.gsub('class=idle', 'class="idle"')
    data = data.gsub('>=', '=')
    data = data.gsub('<=', '=')
    data = data.gsub(/<a href=\S* onclick="return confirm\('Are you sure you want to release DUT [0-9a-zA-Z]{1,} \?'\);"\/>[0-9\?]*<\/a>/, '')
    begin_index = data.index('<tbody>')
    end_index = data.index('</tbody>')
    data = data[begin_index, end_index - begin_index + 8]
    doc = Document.new(data)
    empty = Element.new
    tr_xmls = doc.root
    (tr_xmls||empty).elements.each do |tr|
      td_xml = (tr||empty).elements['td']
      type = (td_xml||empty).attributes['class']
      dut_name = ((td_xml||empty).elements['a']||empty).text
      case mode
      when "all"
        duts << dut_name
      when "idle"
        duts << dut_name if type == "idle"
      when "reserved"
        duts << dut_name if type == "reserved"
      end
    end # end of block
    duts
  end
  private :fetch_duts
  def fetch_doh(dut)
    # puts "Get doh topo from DUT #{dut}"
    data = nil
    server = "#{dut}.sn.stratus.com"
    begin
      req = Net::HTTP::Post.new("http://#{server}/doh/")
      req.body = "<requests output='XML'><request id='1' target='supernova'><watch/></request></requests>"
      req.content_type = 'text/xml'
      Net::HTTP.start(server, 80) do |http|
        response = http.request(req)
        raise "Cannot talk to DUT #{dut}" unless response.code.to_i == 200
        data = response.body
      end
    rescue Exception => e
      # puts "error occured during fetch doh topo from DUT #{dut} => #{e}"
    end
    data
  end
  private :fetch_doh
  def duts(*args)
    mode = args.shift
    duts = mode.nil? ? fetch_duts : fetch_duts(mode)
    duts.each do |dut|
      puts dut
    end
  end
  def find_vcd(dest, pattern, scope, count)
    puts "Find VCD #{dest} begin, this may take a few minutes."
    got_count = 0
    duts = fetch_duts(scope)
    duts.each do |dut|
      break if got_count >= count
      data = fetch_doh(dut)
      next if data.nil?
      root = Document.new(data).root
      empty = Element.new
      outputs_xml = (root.elements['response']||empty).elements['output']
      (outputs_xml||empty).elements.each do |output_xml|
        next unless output_xml.name == 'volume'
        is_iso = ((output_xml.elements['media-info']||empty).elements['isiso']||empty).text.to_bool
        if is_iso
          name = (output_xml.elements['name']||empty).text
          if name.match(Regexp.new(pattern))
            puts "[Result] DUT #{dut} contains a #{dest} VCD"
            got_count += 1
            break
          end
        end
      end # end of volumes_xml block
    end # end of duts block
  end
  def vcd(*args)
    name = args.shift
    count = args.shift
    scope = args.shift || "all"
    raise "vcd name is reuired" if name.nil?
    raise "count is required" if count.nil?
    raise "unsupported scope #{scope}" unless scope == "all" || scope == "idle" || scope == "reserved"
    case name
    when "win2k12"
      find_vcd("win2k12", WIN_2K12_REGEXP, scope, count.to_i)
    else
      puts "TODO"
    end
  end
  def quit
    Kernel.exit
  end
end

com = Commands.new

commands = com.methods - Object.methods

Readline.completion_proc = lambda { |s|
  commands.find_all { |e| e.match(s) }
}

loop do
  line = Readline.readline("> ", true)
  next if line == ""
  if line.nil?
    puts "\n"
    Kernel.exit
  end
  begin
    args = line.split
    command = args.shift
    if com.respond_to? command
      com.send(command.intern, *args)
    else
      puts "unsupported command #{command}"
    end
  rescue SystemExit => exception
    puts "Quitting: #{exception}\n"
    Kernel.exit
  rescue Exception => exception
    puts "Error executing #{line}\n"
    puts " == #{exception} == \n"
  end
end
