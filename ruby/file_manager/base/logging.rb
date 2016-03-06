require 'syslog'
require 'logger'
require 'base/configure'
require 'base/extensions'

class Logger
    class LogDevice
        def add_log_header(file)
        end
    end
    class Formatter
        def timestamp(time)
            time.strftime('%m%d %H:%M:%S.') + ('%06d' % [time.usec.to_s])
        end
        def call(severity, time, progname, message)
            "%s %s %18s %s\n" % [severity[0..0], timestamp(time), "[#{progname}]", message]
        end
    end
end

begin
    log_output_type = $CONFIG[:log_output_type]
    case log_output_type
    when "stdout"
        $log = Logger.new(STDERR)
    when "file"
        log_file = $CONFIG[:log_file] || "../logs/file_manager.log"
        $log = Logger.new(log_file)
    end
rescue Exception => exception
    logWarning {"fatal error initializing debug log => #{exception}"}
end
