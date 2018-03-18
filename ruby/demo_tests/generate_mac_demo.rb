require 'ipaddr'
require 'scanf'
require 'set'

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

    def is_marathon_mac?
        # Is this address in the Avance MAC ranges 00:04:fc:00:xx:xx and 00:04:fc:40:xx:xx
        mac_base = (to_i >> 16)
        is_avance_mac = ((mac_base >= 0x00e00980) && (mac_base <= 0x00e009ff))
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

class Fixnum
    MAX = begin
        if RUBY_PLATFORM == 'java'
            2 ** 63 - 1
        else
            2 ** (0.size * 8 - 2) - 1
        end
    end
    MIN = -MAX - 1
end

$SEED = nil
$MAC_TYPE = :marathon

def gen_rand_num_seeded_by_systime
    current_sys_time_milliseconds = (Time.now.to_r * 1000).to_i
    srand(current_sys_time_milliseconds)
    # Get a random number seeded by current time
    rand(2 ** 17)
end

def address() "192.168.234.1" end

def guest_mac_seed
    $SEED ||= begin
        seed = gen_rand_num_seeded_by_systime
        puts "seed is: #{seed}"
        seed
    end
end

def generate_cluster_id
    seed = guest_mac_seed
    if seed.nil?
        return nil unless address
        puts "guest_mac_seed has not been set, use system address as seed"
        # guest_mac_seed can be nil when this system is upgraded from an old version who is still using IPV4
        # address to generate guest MAC address. In this situation, we should still use the integer format of
        # the system IPV4 address as the guest_mac_seed.
        seed = IPAddr.new(address).to_i
        $SEED = seed
        $MAC_TYPE = :avance
    end
    seed
rescue
    nil
end

def ad_hoc_mac_base
    cluster_id = generate_cluster_id
    return nil unless cluster_id
    # Allocate from the Avance MAC ranges 00:04:fc:00:xx:xx and 00:04:fc:40:xx:xx
    # Or Marathon MAC ranges 00:e0:09:80:xx:xx ~ 00:e0:09:ff:xx:xx
    if $MAC_TYPE == :avance
        cluster_id &= 0x7ff
        mac_base = 0x0004fc000000 + (((cluster_id >> 10)&1) << 22) + ((cluster_id & 0x3ff) << 6)
    else
        # 0000 0000 : 1110 0000 : 0000 1001 : 1RRRRRRR : RRRRRRRR : RR000000 - first network
        mac_base = 0x00e009800000 + (((cluster_id % 2 ** 17) & 0x1ffff) << 6)
    end
    mac_base
end

# def ad_hoc_mac_count() 64 end
def ad_hoc_mac_count() 4 end
def ad_hoc_mac_mask() (1<<48) - ad_hoc_mac_count end
def is_ad_hoc_mac?(mac)
    nmac = MACAddr.new(mac).to_i
    (nmac & ad_hoc_mac_mask == ad_hoc_mac_base)
end

def formatted_mac(type, offset)
    mac = nil
    case type
    when :marathon
        mac = sprintf("00:e0:09:%02x:%02x:%02x",
                      (offset>>16) & 0xff,
                      (offset>>8) & 0xff,
                       offset & 0xff )
    when :avance
        mac = sprintf("00:04:fc:%02x:%02x:%02x",
                      (offset>>16) & 0xff,
                      (offset>>8) & 0xff,
                       offset & 0xff )
    else
        raise "unknown mac type"
    end
    mac
end

def each_ad_hoc_mac
    mac_base = ad_hoc_mac_base or return
    (0..ad_hoc_mac_count-1).each { |i|
        offset = mac_base + i
        mac = formatted_mac($MAC_TYPE, offset)
        yield mac
    }
    nil
end

def mac_range
    $MAC_TYPE = :marathon
    puts "marathon:"
    mac_base = ad_hoc_mac_base or return
    min_mac = formatted_mac($MAC_TYPE, mac_base)
    max_mac = formatted_mac($MAC_TYPE, mac_base + 63)
    puts "#{min_mac} ~ #{max_mac}"

    $MAC_TYPE = :avance
    puts "avance:"
    mac_base = ad_hoc_mac_base or return
    min_mac = formatted_mac($MAC_TYPE, mac_base)
    max_mac = formatted_mac($MAC_TYPE, mac_base + 63)
    puts "#{min_mac} ~ #{max_mac}"
end

def test1
    puts ad_hoc_mac_base
end

def test2
    each_ad_hoc_mac do |mac|
        puts mac
    end
end

def test3
    mac_range
end

def test4
    $MAC_TYPE = :avance
    $MAC_TYPE = :marathon
    seeds = Set.new
    macs = Set.new
    bases = Set.new
    (0..10000).each do |i|
        mac_base = ad_hoc_mac_base
        min_mac = formatted_mac($MAC_TYPE, mac_base)
        # if macs.include?("#{min_mac}")
        #     raise "duplicate mac in #{i}: #{min_mac}"
        if seeds.include?($SEED)
            raise "duplicate seed in #{i}: #{$SEED}"
        # if bases.include?("#{mac_base}")
        #     raise "duplicate base in #{i}: #{mac_base}"
        else
            seeds << $SEED
            # macs << min_mac
            # bases << "#{mac_base}"
        end
        $SEED = nil
        sleep 0.01
    end
end

def test5
    $MAC_TYPE = :avance
    $MAC_TYPE = :marathon
    puts ad_hoc_mac_base
end

def test6
    $MAC_TYPE = :marathon
    mac_base = ad_hoc_mac_base or return
    min_mac = formatted_mac($MAC_TYPE, mac_base)
    max_mac = formatted_mac($MAC_TYPE, mac_base + 63)
    puts "#{min_mac}"
    puts MACAddr.new(min_mac).is_marathon_mac?
    puts "#{max_mac}"
    puts MACAddr.new(max_mac).is_marathon_mac?
end

def test7
    $MAC_TYPE = :marathon
    $SEED = 0
    mac_base = ad_hoc_mac_base
    mac = formatted_mac($MAC_TYPE, mac_base)
    puts mac
    puts MACAddr.new(mac).is_marathon_mac?
    $SEED = 131071
    mac_base = ad_hoc_mac_base
    mac = formatted_mac($MAC_TYPE, mac_base)
    puts mac
    puts MACAddr.new(mac).is_marathon_mac?
end

test7
