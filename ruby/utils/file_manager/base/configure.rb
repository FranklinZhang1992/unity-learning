require 'yaml'

$CONFIG_FILE_PATH = "base/config.yml"
$CONFIG = {}

def parse_config
  config = begin YAML.load(File.open($CONFIG_FILE_PATH)) rescue nil end
  config or raise "Failed to load config file #{$CONFIG_FILE_PATH}"
  log_config = config["log"]
  if log_config.nil?
    $CONFIG[:log_output_type] = "stdout"
  else
    $CONFIG[:log_output_type] = config["log"]["output_type"]
  end
end

parse_config
