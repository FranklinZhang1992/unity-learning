require 'pathname'

class CommandError < RuntimeError ; end

def help?(args)
    return args[0] == "-h" || args[0] == "--help"
end

class UserRepoConfig
    attr :user, :repo_name, :repo_url
    def initialize(configs)
        @user = configs.shift
        @repo_name = configs.shift
        @repo_url = configs.shift
    end
end

class MajorBranchConfig
    attr :val
    def initialize(configs)
        @val = configs.shift
    end
end

class BuildServerConfig
    attr :val
    def initialize(configs)
        @val = configs.shift
    end
end

class BaseDirectoryConfig
    attr :val
    def initialize(configs)
        @val = configs.shift
    end
end

class ConfigLoader

    attr :user_repo_configs, :major_branch_config, :build_server_config, :base_dir_config

    def initialize
        @user_repo_configs = []
        IO.readlines("config").each do |line|
            configs = line.split(" ")
            key = configs.shift
            case key
            when "user-repo"
                @user_repo_configs << UserRepoConfig.new(configs)
            when "major-branch"
                @major_branch_config = MajorBranchConfig.new(configs)
            when "build-server"
                @build_server_config = BuildServerConfig.new(configs)
            when "base"
                @base_dir_config = BaseDirectoryConfig.new(configs)
            else
                puts "unknown config key #{key}"
            end
        end
    end
end

def config_loader() $loader ||= ConfigLoader.new end

def current_user
    %x{whoami}.chomp
end

def get_pool_base
    base = begin
               config_loader.base_dir_config.val
           rescue
               puts "no pool base defined, use default pool base: /developer"
               "/developer"
           end
    File.join(base, current_user)
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
    config_loader.build_server_config.val
rescue
    puts "no build serer defined, use default build server: shanghai12"
    "shanghai12"
end

def major_branch
    config_loader.major_branch_config.val
rescue
    puts "no major branch defined, use default major branch: master"
    "master"
end

def checkout_branch(branch)
    exec_cmd("git checkout #{branch}")
    output = %x{git branch | grep "* #{branch}"}
    puts output
    $?.success? or raise CommandError, "failed to checkout to branch #{branch}"
    branch
end
