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

module SuperNova
    class HMREvent

        MONITOR_INCIDENT_INTERVAL = 1000 * 60 * 60 * 24 # 24h in milliseconds

        attr_reader :type # HostOS, GuestOS or GuestApp
        attr_reader :name # CPU, Memory or Disk
        attr_reader :target # Node name or domain name
        attr_reader :status # warning
        attr_reader :epoch # millisecond epoch

        def initialize(type, name, target, status, epoch)
            @type = type
            @name = name
            @target = target
            @status = status
            @epoch = epoch
        end

        def millisecond_epoch() (Time.now.to_f * 1000).to_i end

        #
        # Check if the incident happens within last 24h
        #
        def within_last_24h?
            return self.epoch >= (millisecond_epoch - MONITOR_INCIDENT_INTERVAL)
        end

        # include REXML

        def to_xml
            Document.new(get_string).root
        end

        def get_string
            xml_string = "<event type=\""<< self.type.to_s << "\">"
            xml_string << "<name>" << self.name.to_s << "</name>"
            xml_string << "<status>" << self.status.to_s << "</status>"
            xml_string << "</event>"
            xml_string
        end
    end

    class HostOSHMREvent < HMREvent
        def initialize(name, node_name, status, epoch)
            super(:HostOS, name, node_name, status, epoch)
        end
    end

    class GuestOSHMREvent < HMREvent
        def initialize(name, domain_name, status, epoch)
            super(:GuestOS, name, domain_name, status, epoch)
        end
    end

    class GuestAppHMREvent < HMREvent
        attr_reader :app_name
        def initialize(name, domain_name, status, epoch, app_name)
            super(:GuestApp, name, domain_name, status, epoch)
            @app_name = app_name
        end
    end
end

class Demo

    def load_monitor_xml_generic(xml, xpath, &block)
        target_name = xml.attributes['name']
        xml.each_element(xpath) do |service_ele|
            service_ele.each_element('stats/stat') do |stat_ele|
                name = stat_ele.elements['name'].text
                status = stat_ele.elements['status'].text
                if status == "warning"
                    event = block.call(service_ele, name, target_name, status)
                end
            end
        end
    end
    def load_monitor_xml_host(host_xml, check_epoch)
        load_monitor_xml_generic(host_xml, "services/service[@type='HostOS']") do |service_ele, name, node_name, status|
            event = SuperNova::HostOSHMREvent.new(name, node_name, status, check_epoch)
        end
    end

    def load_monitor_xml_guest(guest_xml, check_epoch)
        load_monitor_xml_generic(guest_xml, "services/service[@type='GuestOS']") do |service_ele, name, domain_name, status|
            event = SuperNova::GuestOSHMREvent.new(name, domain_name, status, check_epoch)
        end
        load_monitor_xml_generic(guest_xml, "services/service[@type='GuestApp']") do |service_ele, name, domain_name, status|
            app_name = service_ele.attributes['name']
            event = SuperNova::GuestAppHMREvent.new(name, domain_name, status, check_epoch, app_name)
        end
    end
    def check(check_epoch)
        monitoring_hosts = []
        monitoring_guests = []
        monitoring_apps = []
        monitor_xml = Document.new(IO.saferead('monitor.xml', nil)).root
        monitor_xml.each_element do |os_ele|
            next unless os_ele.name == "OS"
            type = os_ele.attributes['type']
            case type
            when "Host"
                load_monitor_xml_generic(os_ele, "services/service[@type='HostOS']") do |service_ele, name, node_name, status|
                    monitoring_hosts << node_name
                    event = SuperNova::HostOSHMREvent.new(name, node_name, status, check_epoch)
                end
            when "Guest"
                load_monitor_xml_generic(os_ele, "services/service[@type='GuestOS']") do |service_ele, name, domain_name, status|
                    monitoring_guests << domain_name
                    event = SuperNova::GuestOSHMREvent.new(name, domain_name, status, check_epoch)
                end
                load_monitor_xml_generic(os_ele, "services/service[@type='GuestApp']") do |service_ele, name, domain_name, status|
                    app_name = service_ele.attributes['name']
                    monitoring_apps << app_name
                    event = SuperNova::GuestAppHMREvent.new(name, domain_name, status, check_epoch, app_name)
                end
            end # End of case 'type'
        end # End of monitor_xml.each
        p monitoring_hosts
        p monitoring_guests
        p monitoring_apps
    end
end

demo = Demo.new
monitor_xml_stat = File.stat('monitor.xml')
millisecond_epoch = (monitor_xml_stat.mtime.to_f * 1000).to_i
demo.check(millisecond_epoch)

