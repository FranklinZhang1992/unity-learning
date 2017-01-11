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
    CRONTAB_ASTERISK_FIELD_REGEXP = Regexp.new('')
    CRONTAB_FIELD_REGEXP = Regexp.new('^*|(\d+(-\d+)?)(/\d+)?$')

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
        raise "a NIL crontab is received" if line.nil?
        crontab = line.split(' ')
        len = crontab.length
        if len != 5
            raise "wrong number of crontab trigger: #{len} (must be 5 -- minute, hour, day of month,  month, day of week)"
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
            "#{line} does not match crontab trigger pattern"
        end
    end

    def init_crontab_field_checker
        @crontab_field_checker_table = Hash.new
        @crontab_field_checker_table[:asterisk] = lambda do |symbol, value|
            
        end
        @crontab_field_checker_table[:minute] = lambda do |value|
            
        end
        @crontab_field_checker_table[:hour]
        @crontab_field_checker_table[:day]
        @crontab_field_checker_table[:month]
        @crontab_field_checker_table[:weekday]
    end

    def property_setter(symbol, value)
        if value =~ /\*/
            @crontab_field_checker_table[:asterisk].call(symbol, value)
        else
            @crontab_field_checker_table[symbol].call(value)
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

    def asterisk_validate(type, step=nil)
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
        end
    end

    def minute_num_validate(start, stop=nil, step=nil)
        raise "minute field #{start} must not be smaller than #{min}" if start < MINUTE_RANGE[:min]
        raise "minute field #{stop} must not be greater than #{min}" if stop > MINUTE_RANGE[:max]
    end

    def hour_num_validate(start, stop=nil, step=nil)
        raise "hour field #{start} must not be smaller than #{min}" if start < HOUR_RANGE[:min]
        raise "hour field #{stop} must not be greater than #{min}" if stop > HOUR_RANGE[:max]
    end

    def day_num_validate(start, stop=nil, step=nil)
        raise "day of month field #{start} must not be smaller than #{min}" if start < DAY_RANGE[:min]
        raise "day of month field #{stop} must not be greater than #{min}" if stop > DAY_RANGE[:max]
    end

    def month_num_validate(start, stop=nil, step=nil)
        raise "month field #{start} must not be smaller than #{min}" if start < MONTH_RANGE[:min]
        raise "month field #{stop} must not be greater than #{min}" if stop > MONTH_RANGE[:max]
    end

    def weekday_num_validate(start, stop=nil, step=nil)
        raise "day of week field #{start} must not be smaller than #{min}" if start < WEEKDAY_RANGE[:min]
        raise "day of week field #{stop} must not be greater than #{min}" if stop > WEEKDAY_RANGE[:max]
    end

    def show
        puts "minute = #{self.minute}, hour = #{self.hour}, day = #{self.day}, month = #{self.month}, weekday = #{self.weekday}"
    end
end

begin
    line = "*6-10 0-23/6 *  1,3,5/2 5"
    # checker = CrontabChecker.new(line)
    CRONTAB_ASTERISK_FIELD_REGEXP = Regexp.new('^(\*)(/(\d+))?$')
    CRONTAB_FIELD_REGEXP = Regexp.new('^(\d+)(-(\d+))?(/(\d+))?$')
    field1 = "3/5" # 1 5
    field2 = "1-7/5" # 1 3 5
    field3 = "*/5" # 1 3
    field4 = "*" # 1
    field5 = "6" # 1
    match = CRONTAB_ASTERISK_FIELD_REGEXP.match(field4)
    p match
    # checker.show
rescue Exception => e
    raise
end
