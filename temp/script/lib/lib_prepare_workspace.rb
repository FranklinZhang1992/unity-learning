require 'fileutils'
require 'pathname'
require "#{File.join(Pathname.new(File.dirname(__FILE__)).realpath.parent, "lib")}/lib_common"

def validate(workspace)
    raise CommandError, "workspace is required" if workspace.nil?
end

def create_workspace_dir(workspace)
    base_dir = get_pool_base
    workspace_full_path = File.join(base_dir, workspace)
    FileUtils.mkdir_p(workspace_full_path)
    puts "created workspace #{workspace_full_path}"
    workspace_full_path
end

def fetch_source_code(workspace_full_path)
    dir = workspace_full_path
    # Clone source code
    FileUtils.cd(dir) do
        exec_cmd("git clone git@github.com:stratustech/unity-stratus")
        raise CommandError, "failed to pull unity-stratus" unless File.exist?("unity-stratus")
        checkout_branch(major_branch)
        exec_cmd("ln -s unity-stratus unity-build")
        dir = File.join(dir, "unity-stratus")
    end
    FileUtils.cd(dir) do
        ["unity-drivers", "unity-third-party", "unity-libvirt", "unity-ui"].each do |repo|
            exec_cmd("git clone git@github.com:stratustech/#{repo}.git")
            FileUtils.cd(File.join(dir, repo)) do
                checkout_branch(major_branch)
            end
        end
    end
end

def add_remote(workspace_full_path)
    config_loader = ConfigLoader.new
    config_loader.user_repo_configs.each do |user_repo_conf|
        if current_user == user_repo_conf.user
            if "unity-stratus" == user_repo_conf.repo_name
                FileUtils.cd(File.join(workspace_full_path, "unity-stratus")) do
                    exec_cmd("git remote add fork #{user_repo_conf.repo_url}")
                end
            else
                FileUtils.cd(File.join(workspace_full_path, "unity-stratus", user_repo_conf.repo_name)) do
                    exec_cmd("git remote add fork #{user_repo_conf.repo_url}")
                end
            end
        end
    end
end

def compile(workspace)
    compile_script = File.join(get_pool_base, "script", "assist_shells", "generic_compile")
    workspace_full_path = File.join(get_pool_base, workspace)
    exec_cmd("ssh #{current_user}@#{build_server} #{compile_script} #{workspace_full_path}")
end
