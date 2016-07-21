class Container
    OVERHEAD_FUDGE_FACTOR = 0.95
    DISK_IMAGE_OVERHEAD_COEFFICIENT = 0.01
    DISK_IMAGE_OVERHEAD_FIXED = (10*1024*1024)
    attr_accessor :path
    def initialize(path)
        self.path = path
    end
    def mountpoint
        self.path
    end
    def df
        cmd = "df -P \"#{mountpoint}\""
        result = %x{#{cmd} 2>&1}
        unless $? == 0
            puts "#{mountpoint}: '#{cmd}' failed with #{result}"
            return nil
        end
        result
    end
    def fs_size_free
        df_line = df
        if df_line.nil?
            return 0
        else
            value = df_line.split("\n").last.split[3].to_i * 1024
            return value
        end
    end
    def size_usable(flavor, ignore_disk_image = nil)
        free = fs_size_free
        overhead = 0
        merge = 0
        puts "#{flavor}: #{free} free, #{overhead} reserved for existing disk images, #{merge} reserved for merges"
        total_reserved = overhead + merge
        return 0 if total_reserved >= free
        return free - total_reserved
    end
    def disk_image_overhead_coefficient
        DISK_IMAGE_OVERHEAD_COEFFICIENT
    end
    def disk_image_overhead_fixed
        DISK_IMAGE_OVERHEAD_FIXED
    end
    def disk_image_overhead(size)
        ((disk_image_overhead_coefficient)*size).ceil + disk_image_overhead_fixed
    end

    def space_to_snapshot_disk_image?(disk_image)
        free = size_usable(:snapshot, disk_image)
        merge_extra = 0
        writable_size = disk_image.size
        required_overhead = disk_image_overhead(writable_size)
        available_overhead = free - (writable_size + merge_extra)
        if (OVERHEAD_FUDGE_FACTOR * required_overhead) > available_overhead
            puts "insufficient free space to snapshot disk image #{disk_image.name} (#{writable_size}+#{required_overhead} (+#{merge_extra}) required, #{free} available)"
            return false
        else
            return true
        end
    end
end

class Image
    attr_accessor :path
    def initialize(path)
        self.path = path
    end
    def size
        File.size?(self.path)
    end
end

begin
    puts "Input container path:"
    container_path = gets.chomp
    puts "Input image path:"
    image_path = gets.chomp
    container = Container.new(container_path)
    image = Image.new(image_path)
    container.space_to_snapshot_disk_image?(image)
rescue Exception => e
    raise
end
