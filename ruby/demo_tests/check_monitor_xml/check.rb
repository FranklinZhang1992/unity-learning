require 'rexml/document'
include REXML

class IO
    class << self
        alias_method :__original_read__, :read
    end

    def self.saferead(filename, default)
        IO.__original_read__(filename)
    rescue Exception
        default
    end
end

class Demo

    def gen_hmrevent(stat_xml, type)
        puts "type: #{type}"
        puts "name: #{stat_xml.elements['name'].text}"
        puts "value: #{stat_xml.elements['value'].text.to_f}"
        puts "status: #{stat_xml.elements['status'].text}"
        puts "======================="
    end
    def load_monitor_xml_host(host_xml)
        node_name = host_xml.attributes['name']
        host_xml.each_element("services/service[@type='HostOS']") do |service_ele|
            service_ele.each_element('stats/stat') do |stat_ele|
                gen_hmrevent(stat_ele, :HostOS)
            end
        end
    end

    def load_monitor_xml_guest(guest_xml)
        domain_name = guest_xml.attributes['name']
        guest_xml.each_element("services/service[@type='GuestOS' or @type='GuestApp']") do |service_ele|
            if service_ele.attributes['type'] == 'GuestOS'
                service_ele.each_element('stats/stat') do |stat_ele|
                    gen_hmrevent(stat_ele, :GuestOS)
                end
            elsif service_ele.attributes['type'] == 'GuestApp'
                service_ele.each_element('stats/stat') do |stat_ele|
                    gen_hmrevent(stat_ele, :GuestApp)
                end
            end
        end
    end
    def check
        monitor_xml = Document.new(IO.saferead('monitor.xml', nil)).root
        monitor_xml.each_element do |os_ele|
            next unless os_ele.name == "OS"
            type = os_ele.attributes['type']
            self.send("load_monitor_xml_#{type.downcase}", os_ele)
        end
    end
end

demo = Demo.new
demo.check

