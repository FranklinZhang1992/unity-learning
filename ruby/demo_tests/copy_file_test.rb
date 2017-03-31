require 'fileutils'

class Dir
    def self.empty?(path)
        # Use FNM_DOTMATCH to match Unix-like hidden files (dotfiles)
        Dir.glob("#{ path }/*", File::FNM_DOTMATCH) do |e|
            return false unless %w{. ..}.include?(File.basename(e))
        end
        return true
    end
end

def get_latest_suffix(dir)
    latest_suffix = 0
    Dir.glob("#{dir}/*") do |f|
        file_name = File.basename(f)
        pattern = Regexp.new("#{$base_name}([0-9]*)$")
        matched = pattern.match(file_name)
        suffix = matched[1].to_i if matched
        latest_suffix = suffix if suffix > latest_suffix
    end
    return latest_suffix
end

def copy(dest, file)
    puts "copy"
    raise "destination can only be a directory" unless File.directory?(dest)
    max_suffix = 0
    if Dir.empty?(dest)
        FileUtils.cp(file, dest)
    else
        latest_suffix = get_latest_suffix(dest)
        new_file = "#{File.basename(file)}#{latest_suffix + 1}"
        FileUtils.cp(file, "#{dest}/#{new_file}")
    end
end

begin
    test_dir = "/developer/test_pool"
    test_file = "/developer/test"
    $base_name = "test"
    copy(test_dir, test_file)
    # copy(test_dir, test_file)
rescue Exception => e
    raise
end
