$raise_immediately = true
$errors = []

def error
    if $raise_immediately
        raise InvalidCrontabError, yield
    else
        $errors << yield
    end
end

class InvalidCrontabError < RuntimeError ; end

class AbstractCrontabField

    attr :start
    attr :stop
    attr :step
    attr :abstract
    attr :field_content

    CRONTAB_ASTERISK_FIELD_REGEXP = Regexp.new('^(\*)(/(\d+))?$')
    CRONTAB_COMMA_FIELD_REGEXP = Regexp.new('^(\d+,)+\d+$')
    CRONTAB_FIELD_REGEXP = Regexp.new('^(\d+)(-(\d+))?(/(\d+))?$')
    ASTERISK_FIELD_STEP_GROUP_NUM = 3
    CRONTAB_FIELD_START_GROUP_NUM = 1
    CRONTAB_FIELD_STOP_GROUP_NUM = 3
    CRONTAB_FIELD_STEP_GROUP_NUM = 5

    def initialize(str, min, max, field)
        case str
        when /\*/
            @abstract = true
            matched = CRONTAB_ASTERISK_FIELD_REGEXP.match(str)
            if matched
                @step = matched[ASTERISK_FIELD_STEP_GROUP_NUM]
                init_params
                range_check(min, max, field)
            else
                error {"#{str} does not match #{field} pattern"}
            end
        when /,/
            matched = CRONTAB_COMMA_FIELD_REGEXP.match(str)
            if matched
                field_strs = str.split(',')
                field_strs.each do |field_str|
                    @start = field_str
                    @stop = field_str
                    init_params
                    range_check(min, max, field)
                end
            else
                error {"#{str} does not match #{field} pattern"}
            end
        else
            matched = CRONTAB_FIELD_REGEXP.match(str)
            if matched
                @start = matched[CRONTAB_FIELD_START_GROUP_NUM]
                @stop = matched[CRONTAB_FIELD_STOP_GROUP_NUM]
                @step = matched[CRONTAB_FIELD_STEP_GROUP_NUM]
                init_params
                range_check(min, max, field)
            else
                error {"#{str} does not match #{field} pattern"}
            end
        end
        @field_content = str
    end

    def init_params
        @start = start.to_i
        @stop = stop.nil? ? @start : stop.to_i
        @step = step.nil? ? 1 : step.to_i
        if @step > 1 and @stop == @start and !@asterisk
            error {"stepping must be used with ranges or asterisk only"}
        end
    end

    def range_check(min, max, field)
        unless @abstract == true
            error {"#{field} field #{start} must not be smaller than #{min}"}if @start < min
            error {"#{field} field #{stop} must not be greater than #{max}"} if @stop > max
        end
        error {"#{field} field #{step} must not be smaller than #{min}"} if @step < min
        error {"#{field} field #{step} must not be greater than #{max}"} if @step > max
    end

    def to_s
        "#{@field_content}"
    end
end

class CrontabMinuteField < AbstractCrontabField
    MIN = 0
    MAX = 59
    FIELD = "minute"
    def initialize(str)
        super(str, MIN, MAX, FIELD)
    end
end

class CrontabHourField < AbstractCrontabField
    MIN = 0
    MAX = 23
    FIELD = "hour"
    def initialize(str)
        super(str, MIN, MAX, FIELD)
    end
end

class CrontabDayField < AbstractCrontabField
    MIN = 1
    MAX = 31
    FIELD = "day of month"
    def initialize(str)
        super(str, MIN, MAX, FIELD)
    end
end

class CrontabMonthField < AbstractCrontabField
    MIN = 1
    MAX = 12
    FIELD = "month"
    def initialize(str)
        super(str, MIN, MAX, FIELD)
    end
end

class CrontabWeekdayField < AbstractCrontabField
    MIN = 0
    MAX = 7
    FIELD = "day of week"
    def initialize(str)
        super(str, MIN, MAX, FIELD)
    end
end

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

    CRONTAB_TRIGGER_REGEXP = Regexp.new('^([-/,*\d]+)\s+([-/,*\d]+)\s+([-/,*\d]+)\s+([-/,*\d]+)\s+([-/,*\d]+)$')
    MINUTE_GROUP_NUM = 1
    HOUR_GROUP_NUM = 2
    DAY_GROUP_NUM = 3
    MONTH_GROUP_NUM = 4
    WEEKDAY_GROUP_NUM = 5

    def check_crontab_str(str)
        error {"a NIL crontab is received"} if str.nil?
        crontab = str.split(' ')
        len = crontab.length
        if len != 5
            error {"wrong number of crontab trigger: #{len} (must be 5 -- minute, hour, day of month,  month, day of week)"}
        end

        matched = CRONTAB_TRIGGER_REGEXP.match(str)
        if matched
            self.minute = matched[MINUTE_GROUP_NUM]
            self.hour = matched[HOUR_GROUP_NUM]
            self.day = matched[DAY_GROUP_NUM]
            self.month = matched[MONTH_GROUP_NUM]
            self.weekday = matched[WEEKDAY_GROUP_NUM]
        else
            error {"#{str} does not match crontab trigger pattern"}
        end
        puts "verify success"
    end

    CRONTAB_FIELD_CLASS_TABLE = {
        :minute => CrontabMinuteField,
        :hour => CrontabHourField,
        :day => CrontabDayField,
        :month => CrontabMonthField,
        :weekday => CrontabWeekdayField
    }

    def get_field_class(field)
        CRONTAB_FIELD_CLASS_TABLE[field]
    end

    def property_setter(symbol, value)
        error {"a NIL field is received"} if value.nil?
        instance_variable_set("@#{symbol}", get_field_class(symbol).new(value))
    end

    def show
        puts "minute = #{self.minute}, hour = #{self.hour}, day = #{self.day}, month = #{self.month}, weekday = #{self.weekday}"
    end
end

test_crontab_str = lambda do |str, expect|
    begin
        puts "=================================================================="
        puts "check for #{str}, expect result '#{expect}'"
        checker = CrontabChecker.new
        checker.check_crontab_str(str)
    rescue Exception => err
        case err
        when InvalidCrontabError
            puts "[ERROR] #{err.message}"
        else
            detail = err.backtrace.join("\n")
            puts "[ERROR] #{err.message} =>\n#{detail}"
        end
    ensure
        puts "=================================================================="
    end
end

test_crontab_str.call("* 1-12 1-31/5 * *", "correct") # correct
test_crontab_str.call("* 1-30 1-31/5 * *", "wrong") # wrong
test_crontab_str.call("* 22,23 1-31/5 * *", "correct") # correct
test_crontab_str.call("* 22,24 1-31/5 * *", "wrong") # wrong
test_crontab_str.call("-1 * * * *", "wrong, out of range")        # wrong, out of range
test_crontab_str.call("5/2 * * * *", "wrong")       # wrong
test_crontab_str.call("0-30/10 * * * *", "correct")   # correct
test_crontab_str.call("0-30-/10 * * * *", "wrong")  # wrong
test_crontab_str.call("0-30//10 * * * *", "wrong")  # wrong
test_crontab_str.call("0-30/2-10 * * * *", "wrong")  # wrong
test_crontab_str.call("0-30/2,10 * * * *", "wrong")  # wrong
test_crontab_str.call("0-30/2,10/5 * * * *", "wrong")  # wrong
test_crontab_str.call("10,4,8, * * * *", "wrong")   # wrong
