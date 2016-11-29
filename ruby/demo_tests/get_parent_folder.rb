def dir_empty?(path)
    Dir.glob("#{ path }/*", File::FNM_DOTMATCH) do |e|
        puts "e = #{e}, base name = #{File.basename(e)}"
        return false unless %w{. ..}.include?(File.basename(e))
    end
    return true
end

def delete(file)
    if !file.nil? && File.file?(file)
        parent = File.dirname(file)
        # File.delete(file)
        dir_empty = dir_empty?(parent)
        puts dir_empty
    end
end

begin
    folder = "/tmp/test_folder"
    file = "#{folder}/test_file"
    %x{mkdir #{folder}} unless File.exist?(folder)
    %x{touch #{file}} unless File.exist?(file)
    delete(file)
    %x{rm -rf #{folder}}
rescue Exception => e
    raise
end
