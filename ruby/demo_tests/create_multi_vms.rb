#!/usr/bin/ruby

require 'rexml/document'
require 'net/http'
require 'cgi'
require 'set'

include REXML

class Main
  DOH_USERNAME = "admin"
  DOH_PASSWORD = "admin"
  def fetch_doh_session
    session = nil
    session_id = rand(100)
    server = "localhost"
    begin
      req = Net::HTTP::Post.new("http://#{server}/doh/")
      req.body = "<requests output='XML'><request id='#{session_id}' target='session'><login><username>#{DOH_USERNAME}</username><password>#{DOH_PASSWORD}</password></login></request></requests>"
      req.content_type = 'text/xml'
      Net::HTTP.start(server, 80) do |http|
        response = http.request(req)
        raise "Cannot talk to DOH" unless response.code.to_i == 200
        data = response.body
        unless data.nil?
          root = Document.new(data).root
          empty = Element.new
          login_xml = (root.elements['response']||empty).elements['login']
          status = (login_xml||empty).attributes['status']
          if status == "ok"
            session = ((login_xml||empty).elements['session-id']||empty).text
          end
        end
      end
    rescue Exception => e
      puts "error occured during fetch doh session => #{e}"
    end
    session
  end
  def do_doh_request(request_body)
    data = nil
    server = "localhost"
    begin
      session = fetch_doh_session
      req = Net::HTTP::Post.new("http://#{server}/doh/")
      req.body = "<requests output='XML'>#{request_body}</requests>"
      req.content_type = 'text/xml'
      unless session.nil?
        cookie = CGI::Cookie.new("JSESSIONID", "#{session}")
        req['Cookie'] = cookie.to_s
      end
      Net::HTTP.start(server, 80) do |http|
        response = http.request(req)
        raise "Cannot talk to DOH" unless response.code.to_i == 200
        data = response.body
        root = Document.new(data).root
        empty = Element.new
        status = (root.elements['response']||empty).attributes['status']
        unless status == "ok"
          data = nil
        end
      end # end of Net::HTTP.start block
    rescue Exception => e
      puts "error occured during fetch doh topo from DOH => #{e}"
    end
    data
  end
  def run(num)
    ft_vm_count = 0
    for i in 0 .. num - 1 do
      vm_name = "MyVM#{i}"
      session_id = rand(100)
      option = rand(2)
      availability = "HA"
      if option == 1 && ft_vm_count < 5
        availability = "FT"
        ft_vm_count += 1
      end
      create_vm_request_body = "<request id=\"#{session_id}\" target=\"vm\"><create-dynamic><name><![CDATA[#{vm_name}]]></name><description><![CDATA[]]></description><virtual-cpus>1</virtual-cpus><memory>1024</memory><vnc-keyboard-layout>en-us</vnc-keyboard-layout><availability-level>#{availability}</availability-level><installation-template>template:o306</installation-template><autostart>true</autostart><volumes><volume from=\"sharedstorage:o109\"><size>20480</size><logical-sector-size>512</logical-sector-size><image-type>RAW</image-type><container-size>20480</container-size><name><![CDATA[#{vm_name}_boot]]></name></volume><volume ref=\"volume:o2724\" /></volumes><networks><network ref=\"sharednetwork:o1379\" /></networks></create-dynamic></request>"
      puts "will create VM #{vm_name}"
      data = do_doh_request(create_vm_request_body)
      unless data.nil?
        puts "Successfully created VM #{vm_name}"
      end
    end # end of for
  end
end

begin
  puts "input total vm number:"
  num = gets.chomp.to_i
  main = Main.new
  main.run(num)
rescue Exception => e
  raise
end
