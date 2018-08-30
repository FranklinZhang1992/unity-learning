require 'singleton'
require 'rexml/document'
include REXML

DST_FILE = 'mockup'
DST_FILE_PEER = 'mockup.peer'

def output_format(src)
    formatted = ""
    format_size = 8
    for i in 0...(format_size - src.length) do
        formatted << " "
    end
    formatted << src
    formatted
end


class HMRStat
    attr :description
    attr :value
    attr :units
    attr :status

    def initialize(description, value)
        @description =  description
        @value = value.nil? ? (rand(15) + 55) : value
        @units = "pc"
        @status = @value > 60 ? "warning" : "normal"
    end

    def warning?
        self.status == "warning"
    end

    def to_xml
        "<stat><description>#{self.description}</description><value>#{self.value}</value><units>#{self.units}</units><status>#{self.status}</status></stat>"
    end
end

class HostCpuStat < HMRStat
    def initialize(value=nil)
        super("Host CPU usage", value)
    end
end

class HostMemStat < HMRStat
    def initialize(value=nil)
        super("Host Mem usage", value)
    end
end

class GuestCpuStat < HMRStat
    def initialize(value=nil)
        super("Guest CPU usage", value)
    end
end

class GuestMemStat < HMRStat
    def initialize(value=nil)
        super("Guest Mem usage", value)
    end
end

class GuestDiskStat < HMRStat
    def initialize(value=nil)
        super("Guest Disk usage", value)
    end
end

class GuestAppCpuStat < HMRStat
    def initialize(value=nil)
        super("Guest CPU usage", value)
    end
end

class GuestAppMemStat < HMRStat
    def initialize(value=nil)
        super("Guest Mem usage", value)
    end
end

class MonitoringService
    attr :type
    attr :name
    attr :stats
    attr :description
    def initialize(type, name, description, stats)
        @type = type
        @name = name
        @stats = stats
        @description = description
    end

    def to_xml
        xml = "<service type=\"#{self.type}\" name=\"#{self.name}\"><description>#{self.description}</description><stats>"
        self.stats.each do |stat|
            xml << stat.to_xml
        end
        xml << "</stats></service>"
        xml
    end
end

class HostOSMonitoringService < MonitoringService
    def initialize(stats)
        super("HostOS", "System", "Host OS statistics", stats)
    end
end

class GuestOSMonitoringService < MonitoringService
    def initialize(stats)
        super("GuestOS", "System", "Guest OS statistics", stats)
    end
end

class GuestAppMonitoringService < MonitoringService
    def initialize(stats)
        super("GuestApp", "app_exe", "Guest App statistics", stats)
    end
end

class MonitoringOS
    attr :type
    attr :name
    attr :services
    def initialize(type, name, services)
        @type = type
        @name = name
        @services = services
    end

    def expect_name
        @exp_name = self.name
        @exp_name = $1 if self.name =~ /^(node[0,1])(\w*)?/
        @exp_name
    end

    def to_xml
        xml = "<OS type=\"#{self.type}\" name=\"#{self.name}\"><services>"
        self.services.each do |service|
            xml << service.to_xml
        end
        xml << "</services></OS>"
        xml
    end
end

class HostMonitoringOS < MonitoringOS
    def initialize(host_name, services)
        super("Host", host_name, services)
    end
end

class GuestMonitoringOS < MonitoringOS
    def initialize(guest_name, services)
        super("Guest", guest_name, services)
    end
end

class MonitoringXMLProvider
    attr :monitoring_oses
    def initialize(monitoring_oses)
        @monitoring_oses = monitoring_oses
    end

    def expected_result
        expected = ""
        self.monitoring_oses.each do |os|
            os_type = os.type
            os_name = os.expect_name
            os.services.each do |service|
                srv_type = service.type
                srv_name = service.name
                service.stats.each do |stat|
                    next unless stat.warning?
                    expected << "\tOS type: #{output_format(os_type)}, OS name: #{output_format(os_name)}, Service type: #{output_format(srv_type)}, Service name: #{output_format(srv_name)}, Stat: #{output_format(stat.description)}\n"
                end
            end
        end
        expected
    end

    def to_xml
        xml = "<Monitoring>"
        self.monitoring_oses.each do |os|
            xml << os.to_xml
        end
        xml << "</Monitoring>"
        xml
    end
end

class Tester
    attr :hostcpu
    attr :hostmem
    attr :guestcpu
    attr :guestmem
    attr :guestdisk
    attr :guestappcpu
    attr :guestappmem

    attr :hostsrv
    attr :guestsrv
    attr :guestappsrv

    def initialize
        @hostcpu = HostCpuStat.new
        @hostmem = HostMemStat.new
        @guestcpu = GuestCpuStat.new
        @guestmem = GuestMemStat.new
        @guestdisk = GuestDiskStat.new
        @guestappcpu = GuestAppCpuStat.new
        @guestappmem = GuestAppMemStat.new

        @hostsrv = HostOSMonitoringService.new([self.hostcpu, self.hostmem])
        @guestsrv = GuestOSMonitoringService.new([self.guestcpu, self.guestmem, self.guestdisk])
        @guestappsrv = GuestAppMonitoringService.new([self.guestappcpu, self.guestappmem])
    end
    def node0_xml_mockup
        hostos = HostMonitoringOS.new("node0.cobra1bc.sn.stratus.com", [self.hostsrv])
        guestos = GuestMonitoringOS.new("greece1", [self.guestsrv, self.guestappsrv])
        node0_provider = MonitoringXMLProvider.new([hostos, guestos])
    end
    def node1_xml_mockup
        hostos = HostMonitoringOS.new("node1.cobra1bc.sn.stratus.com", [self.hostsrv])
        guestos = GuestMonitoringOS.new("greece2", [self.guestsrv, self.guestappsrv])
        node1_provider = MonitoringXMLProvider.new([hostos, guestos])
    end

    def spine_topology
        # output = %x{curl http://localhost:8999/topology.xml}
        output = %x{cat spine_topo.xml}
    end

    def analyze_hmr_event_topo(event_parent_topo, entity_name)
        msg = ""
        event_parent_topo.each_element("hmr-events/event") do |hmr_event_ele|
            event_type = hmr_event_ele.attributes["type"]
            event_name = hmr_event_ele.elements["name"].text
            event_status = hmr_event_ele.elements["status"].text
            if event_status == "warning"
                msg << "Entity name: #{entity_name}, event_type: #{event_type}, event_name: #{event_name}\n"
            end
        end
        msg
    end

    def analyze_spine_topo(spine_topo_doc, node_name, domain_name)
        msg = ""
        spine_topo_doc.each_element("//nodes/node") do |node_ele|
            next unless node_ele.elements["name"].text == node_name
            msg << analyze_hmr_event_topo(node_ele, node_name)
        end
        spine_topo_doc.each_element("//protected-virtual-machines/protected-virtual-machine") do |domain_ele|
            next unless domain_ele.elements["name"].text == domain_name
            msg << analyze_hmr_event_topo(domain_ele, domain_name)
            domain_ele.each_element("//apps/app") do |app_ele|
                app_name = app_ele.elements["name"].text
                msg << analyze_hmr_event_topo(app_ele, app_name)
            end
        end
        msg
    end

    def node0_xml_actual(spine_topo_doc)
        msg = ""
        msg << analyze_spine_topo(spine_topo_doc, "node0", "greece1")
        msg
    end
    def node1_xml_actual(spine_topo_doc)
        msg = ""
        msg << analyze_spine_topo(spine_topo_doc, "node1", "greece2")
        msg
    end

    def run
        # Prepare mock ups
        node0_provider = node0_xml_mockup
        node1_provider = node1_xml_mockup

        # Write mock up file for node0
        %x{echo '#{node0_provider.to_xml}' > #{DST_FILE}}

        # Write mock up file for node1
        # %x{echo '#{node0_provider.to_xml}' > #{DST_FILE_PEER}}
        # %x{scp #{DST_FILE_PEER} root@peer:#{DST_FILE}}
        # %x{rm -f #{DST_FILE_PEER}}

        # Pause and wait for Spine's handling
        # sleep 5

        # Fetch Spine topology
        spine_topo_doc = Document.new(spine_topology).root

        # Print expected results and actual results
        puts "Node0 expected:\n#{node0_provider.expected_result}"
        puts "Node0 actual:\n#{node0_xml_actual(spine_topo_doc)}"

        puts "------------------------------------------------------------------------------------------------------------------------"

        puts "Node1 expected:\n#{node1_provider.expected_result}"
        puts "Node1 actual:\n#{node1_xml_actual(spine_topo_doc)}"

        puts "========================================================================================================================"

    end
end

N = 5
for i in 0...N do
    t = Tester.new
    t.run
    sleep 1
end

