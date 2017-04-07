

def get_vms
    pattern = Regexp.new('\d+\s*(\S*)\s*[a-z]+')
    vms = []
    result = %x{virsh list}
    result.each_line do |line|
        next if line =~ /Id\s*Name\s*State/
        next if line =~ /----------/
        next if line == "\n"
        matched = pattern.match(line)
        if matched
            p matched[1]
        end
    end
end

get_vms
