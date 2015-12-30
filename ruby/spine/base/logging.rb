require 'syslog'
require 'logger'
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
    # logdevice = "#{$log_dir}/spine.log"
    $log = Logger.new(STDERR)
rescue Exception => exception
    logWarning {"fatal error initializing debug log => #{exception}"}
end
