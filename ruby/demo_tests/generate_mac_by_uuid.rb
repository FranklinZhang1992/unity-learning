
require 'ipaddr'
require 'securerandom'

$PERSIST_MAC = nil
$IS_COBRA = false

module Kernel
    def self.uuid() IO.read('/proc/sys/kernel/random/uuid').strip end
end

class MACAddr
    VALID_REGEXP = /^[0-9a-fA-F]{2}(:[0-9a-fA-F]{2}){5}$/
    class << self
        def valid?(address)
            address.match(VALID_REGEXP) != nil # Convert to boolean
        end
    end
    def initialize(address)
        address = address.to_s
        MACAddr.valid?(address) or raise ArgumentError, "Invalid MAC address \"#{address}\""
        @address = address.downcase
    end

    def to_link_local_ipv6
        octets = @address.split(':')
        llv6 = 'fe80::' << sprintf("%02x", 0x02 ^ octets.shift.scanf('%2x').first)
        llv6 << octets.shift << ':' << octets.shift << 'ff:fe' << octets.shift << ':' << octets.shift << octets.shift
        IPAddr.new(llv6).to_s
    end

    def is_avance_mac?
        # Is this address in the Avance MAC ranges 00:04:fc:00:xx:xx and 00:04:fc:40:xx:xx
        mac_base = (to_i >> 16)
        is_avance_mac = ((mac_base == 0x0004fc00) || (mac_base == 0x0004fc40))
        is_avance_mac
    end

    def to_i
        numeric = 0
        @address.split(':').each { |byte| numeric = (numeric << 8) + byte.hex }
        numeric
    end

    def to_s
        @address.to_s
    end
end

def address() "252.64.254.243" end


#####################################
############ Modified ###############
#####################################

def mac_finger_print
    $PERSIST_MAC ||= begin
        uuid_str = Kernel.uuid.gsub('-', '')
        puts "uuid = #{uuid_str}"
        r = uuid_str.to_i(16) & 0x7ff
        puts r
        r
    rescue
        nil
    end
end

def generate_cluster_id
    if $IS_COBRA
        mac_finger_print
    else
        return nil unless address
        addr = IPAddr.new(address).to_i
        addr & 0x7ff
    end
end

def ad_hoc_mac_base
    cluster_id = generate_cluster_id
    return nil unless cluster_id
    # Allocate from the Avance MAC ranges 00:04:fc:00:xx:xx and 00:04:fc:40:xx:xx
    # puts "A: #{((cluster_id >> 10)&1) << 22}"
    # puts "B: #{(cluster_id & 0x3ff) << 6}"
    mac_base = 0x0004fc000000 + (((cluster_id >> 10)&1) << 22) + ((cluster_id & 0x3ff) << 6)
    mac_base
end

############################################################
def ad_hoc_mac_count() 64 end
def ad_hoc_mac_mask() (1<<48) - ad_hoc_mac_count end
def is_ad_hoc_mac?(mac)
    nmac = MACAddr.new(mac).to_i
    puts "is_ad_hoc_mac?, ad_hoc_mac_base = #{ad_hoc_mac_base}, ad_hoc_mac_mask = #{ad_hoc_mac_mask}, compare = #{nmac & ad_hoc_mac_mask}"
    (nmac & ad_hoc_mac_mask == ad_hoc_mac_base)
end

def each_ad_hoc_mac
    mac_base = ad_hoc_mac_base or return
    (0..ad_hoc_mac_count-1).each { |i|
        offset = mac_base + i
        mac = sprintf("00:04:fc:%02x:%02x:%02x",
                      (offset>>16) & 0xff,
                      (offset>>8) & 0xff,
                      offset & 0xff )
        yield mac
    }
    nil
end

def check_mac(mac)
    ad_hoc_mac = is_ad_hoc_mac?(mac)
    avance_mac = MACAddr.new(mac).is_avance_mac?
    puts "is_ad_hoc_mac? => #{ad_hoc_mac}, is_avance_mac? => #{avance_mac}"
    ad_hoc_mac && avance_mac
end

def test1
    count = 0
    each_ad_hoc_mac do |m|
        count += 1
        puts "####(#{count})\n#{m} "
        break unless check_mac(m)
    end
end

def test2
    mac = "00:04:fc:40:ff:ff"
    puts is_ad_hoc_mac?(mac)
end

def test3
    10.times do
        puts "%0x" % ad_hoc_mac_base
        $PERSIST_MAC = nil
    end

end

test3
# check_mac("00:04:fc:00:a3:00")

# ad_hoc_mac_base_test("192.168.234.71")
# ad_hoc_mac_base_test("10.86.5.192")
# ad_hoc_mac_base_test("169.254.250.140")
