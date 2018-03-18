require 'pathname'

class CommandError < RuntimeError ;

def current_user
    %x{whoami}.chomp
end

def get_pool_base
    File.join("/developer", current_user)
end

def exec_cmd(cmd, verbose=true)
    puts "exec: #{cmd}"
    IO.popen(cmd) { |io|
      while line = io.gets
        puts line.chomp if verbose
      end
    }
    $?.success?
end

def build_server
    IO.read("build_server").strip
rescue
    nil
end

class UserRepoConfig
    attr :user, :repo_name, :repo_url
    def initialize(configs)
        @user = configs.shift
        @repo_name = configs.shift
        @repo_url = configs.shift
    end
end

class ConfigLoader

    attr :user_repo_configs

    HANDLERS = {
        "user-repo" => [UserRepoConfig, @user_repo_configs = []]
    }

    def initialize
        @user_repo_configs = []
        IO.readlines("../lib/script.conf").each do |line|
            configs = line.split(" ")
            key = configs.shift
            hanlder = HANDLERS[key]
            case key
            when "user-repo"
                @user_repo_configs << UserRepoConfig.new(configs)
            else
                puts "unknown config key #{key}"
            end
        end
    end
end
