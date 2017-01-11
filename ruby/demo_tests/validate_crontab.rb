class InvalidCrontabError < RuntimeError ; end

class CrontabCheckerBase
    def self.attr_cfg(symbol)
        define_method(symbol) {
            instance_variable_get("@#{symbol}")
        }
        define_method("#{symbol}=") { |value|
            property_setter(symbol, value)
        }
    end
    def self.cron_attr(*symbols)
        symbols.each do |symbol|
            self.attr_cfg(symbol)
        end
    end
end

class CrontabChecker < CrontabCheckerBase

    cron_attr :minute
    cron_attr :hour
    cron_attr :day
    cron_attr :month
    cron_attr :weekday

    # Crontab
    CRONTAB_TRIGGER_REGEXP = Regexp.new('^([-/,*\d]+)\s+([-/,*\d]+)\s+([-/,*\d]+)\s+([-/,*\d]+)\s+([-/,*\d]+)$')
    MINUTE_GROUP_NUM = 1
    HOUR_GROUP_NUM = 2
    DAY_GROUP_NUM = 3
    MONTH_GROUP_NUM = 4
    WEEKDAY_GROUP_NUM = 5

    # Crontab field
    VALID_WEEKDAY = %w{sun mon tue wed thu fri sat}
    VALID_MONTH = %w{jan feb mar apr may jun jul aug sep oct nov dec}
    CRONTAB_ASTERISK_FIELD_REGEXP = Regexp.new('^(\*)(/(\d+))?$')
    CRONTAB_FIELD_REGEXP = Regexp.new('^(\d+)(-(\d+))?(/(\d+))?$')
    ASTERISK_FIELD_STEP_GROUP_NUM = 3
    CRONTAB_FIELD_START_GROUP_NUM = 1
    CRONTAB_FIELD_STOP_GROUP_NUM = 3
    CRONTAB_FIELD_STEP_GROUP_NUM = 5

    MINUTE_RANGE = {
        :min => 0,
        :max => 59
    }
    HOUR_RANGE = {
        :min => 0,
        :max => 23
    }
    DAY_RANGE = {
        :min => 1,
        :max => 31
    }
    MONTH_RANGE = {
        :min => 1,
        :max => 12
    }
    WEEKDAY_RANGE = {
        :min => 0,
        :max => 7
    }


    def initialize(line)
        raise InvalidCrontabError, "a NIL crontab is received" if line.nil?
        crontab = line.split(' ')
        len = crontab.length
        if len != 5
            raise InvalidCrontabError, "wrong number of crontab trigger: #{len} (must be 5 -- minute, hour, day of month,  month, day of week)"
        end
        init_crontab_field_checker
        matched = CRONTAB_TRIGGER_REGEXP.match(line)
        if matched
            self.minute = matched[MINUTE_GROUP_NUM]
            self.hour = matched[HOUR_GROUP_NUM]
            self.day = matched[DAY_GROUP_NUM]
            self.month = matched[MONTH_GROUP_NUM]
            self.weekday = matched[WEEKDAY_GROUP_NUM]
        else
            raise InvalidCrontabError, "#{line} does not match crontab trigger pattern"
        end
    end

    def init_crontab_field_checker
        @crontab_field_checker_table = Hash.new
        @crontab_field_checker_table[:asterisk] = lambda do |type, step|
            puts "asterisk field check for #{type} => step = #{step}"
            return if step.nil?
            min = 0
            max = 0
            case type
            when :minute
                min = MINUTE_RANGE[:min]
                max = MINUTE_RANGE[:max]
            when :hour
                min = HOUR_RANGE[:min]
                max = HOUR_RANGE[:max]
            when :day
                min = DAY_RANGE[:min]
                max = DAY_RANGE[:max]
            when :month
                min = MONTH_RANGE[:min]
                max = MONTH_RANGE[:max]
            when :weekday
                min = WEEKDAY_RANGE[:min]
                max = WEEKDAY_RANGE[:max]
            else
                raise InvalidCrontabError, "unknown type for asterisk validate"
            end
            raise InvalidCrontabError, "#{type} step field must not be smaller than #{min}" if step.to_i < min
            raise InvalidCrontabError, "#{type} step field must not be greater than #{max}" if step.to_i > max
        end
        @crontab_field_checker_table[:minute] = lambda do |start, stop, step|
            puts "crontab field check for minute => start = #{start}, stop = #{stop}, step = #{step}"
            min = MINUTE_RANGE[:min]
            max = MINUTE_RANGE[:max]
            raise InvalidCrontabError, "minute field #{start} must not be smaller than #{min}" if start.to_i < min
            raise InvalidCrontabError, "minute field #{stop} must not be greater than #{max}" if stop.to_i > max unless stop.nil?
            raise InvalidCrontabError, "minute field #{step} must not be smaller than #{min}" if step.to_i < min unless step.nil?
            raise InvalidCrontabError, "minute field #{step} must not be greater than #{max}" if step.to_i > max unless step.nil?
        end
        @crontab_field_checker_table[:hour] = lambda do |start, stop, step|
            puts "crontab field check for hour => start = #{start}, stop = #{stop}, step = #{step}"
            min = HOUR_RANGE[:min]
            max = HOUR_RANGE[:max]
            raise InvalidCrontabError, "hour field #{start} must not be smaller than #{min}" if start.to_i < min
            raise InvalidCrontabError, "hour field #{stop} must not be greater than #{max}" if stop.to_i > max unless stop.nil?
            raise InvalidCrontabError, "hour field #{step} must not be smaller than #{min}" if step.to_i < min unless step.nil?
            raise InvalidCrontabError, "hour field #{step} must not be greater than #{max}" if step.to_i > max unless step.nil?
        end
        @crontab_field_checker_table[:day] = lambda do |start, stop, step|
            puts "crontab field check for day => start = #{start}, stop = #{stop}, step = #{step}"
            min = DAY_RANGE[:min]
            max = DAY_RANGE[:max]
            raise InvalidCrontabError, "day of month field #{start} must not be smaller than #{min}" if start.to_i < min
            raise InvalidCrontabError, "day of month field #{stop} must not be greater than #{max}" if stop.to_i > max unless stop.nil?
            raise InvalidCrontabError, "day of month field #{step} must not be smaller than #{min}" if step.to_i < min unless step.nil?
            raise InvalidCrontabError, "day of month field #{step} must not be greater than #{max}" if step.to_i > max unless step.nil?
        end
        @crontab_field_checker_table[:month] = lambda do |start, stop, step|
            puts "crontab field check for month => start = #{start}, stop = #{stop}, step = #{step}"
            min = MONTH_RANGE[:min]
            max = MONTH_RANGE[:max]
            raise InvalidCrontabError, "month field #{start} must not be smaller than #{min}" if start.to_i < min
            raise InvalidCrontabError, "month field #{stop} must not be greater than #{max}" if stop.to_i > max unless stop.nil?
            raise InvalidCrontabError, "month field #{step} must not be smaller than #{min}" if step.to_i < min unless step.nil?
            raise InvalidCrontabError, "month field #{step} must not be greater than #{max}" if step.to_i > max unless step.nil?
        end
        @crontab_field_checker_table[:weekday] = lambda do |start, stop, step|
            puts "crontab field check for weekday => start = #{start}, stop = #{stop}, step = #{step}"
            min = WEEKDAY_RANGE[:min]
            max = WEEKDAY_RANGE[:max]
            raise InvalidCrontabError, "day of week field #{start} must not be smaller than #{min}" if start.to_i < min
            raise InvalidCrontabError, "day of week field #{stop} must not be greater than #{max}" if stop.to_i > max unless stop.nil?
            raise InvalidCrontabError, "day of week field #{step} must not be smaller than #{min}" if step.to_i < min unless step.nil?
            raise InvalidCrontabError, "day of week field #{step} must not be greater than #{max}" if step.to_i > max unless step.nil?
        end
    end

    def property_setter(symbol, value)
        if value =~ /\*/
            matched = CRONTAB_ASTERISK_FIELD_REGEXP.match(value)
            if matched
                step = matched[ASTERISK_FIELD_STEP_GROUP_NUM]
                @crontab_field_checker_table[:asterisk].call(symbol, step)
            else
                raise InvalidCrontabError, "#{value} does not match #{symbol} pattern"
            end
        else
            matched = CRONTAB_FIELD_REGEXP.match(value)
            if matched
                start = matched[CRONTAB_FIELD_START_GROUP_NUM]
                stop = matched[CRONTAB_FIELD_STOP_GROUP_NUM]
                step = matched[CRONTAB_FIELD_STEP_GROUP_NUM]
                @crontab_field_checker_table[symbol].call(start, stop, step)
            else
                raise InvalidCrontabError, "#{value} does not match #{symbol} pattern"
            end
        end
        instance_variable_set("@#{symbol}", value)
    end

    def valid_month_word?(value)
        return false if value.nil?
        result = false
        month_word = value.downcase
        VALID_MONTH.each do |month|
            next unless month_word == month
            result = true
            break
        end
        result
    end

    def valid_weekday_word?(value)
        return false if value.nil?
        result = false
        weekday_word = value.downcase
        VALID_WEEKDAY.each do |week_day|
            next unless weekday_word == week_day
            result = true
            break
        end
        return result
    end

    def show
        puts "minute = #{self.minute}, hour = #{self.hour}, day = #{self.day}, month = #{self.month}, weekday = #{self.weekday}"
    end
end

begin
    line = "* 1-12 1-31/5 * *" # correct
    checker = CrontabChecker.new(line)
    checker.show

    line2 = "* 1-30 1-31/5 * *" # wrong
    checker2 = CrontabChecker.new(line2)
    checker2.show
rescue Exception => err
    case err
    when RuntimeError
        puts "[ERROR] #{err.message}"
    else
        raise
    end
end
