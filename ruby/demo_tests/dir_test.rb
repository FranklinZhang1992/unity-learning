class Dir
    def self.empty?(path)
        # Use FNM_DOTMATCH to match Unix-like hidden files (dotfiles)
        Dir.glob("#{ path }/*", File::FNM_DOTMATCH) do |e|
            return false unless %w{. ..}.include?(File.basename(e))
        end
        return true
    end
end

p Dir.empty?("/tmp/xxxx")
