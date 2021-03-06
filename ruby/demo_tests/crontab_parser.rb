#!/usr/bin/ruby

require 'set'
require 'date'

class InvalidCrontabError < RuntimeError ; end

class AbstractCrontabField
    attr :field_str
    attr :field_set

    def initialize(field_str, field_set)
        @field_str = field_str
        case field_set
        when Set
            @field_set = field_set
        else
            raise ArgumentError, "invalid set is received"
        end
    end

    def to_s
        "#{self.field_str}"
    end
end

class CrontabMinuteField < AbstractCrontabField
    MIN = 0
    MAX = 59
    FIELD = "minute"
    def initialize(field_str, field_set)
        super(field_str, field_set)
    end
end

class CrontabHourField < AbstractCrontabField
    MIN = 0
    MAX = 23
    FIELD = "hour"
    def initialize(field_str, field_set)
        super(field_str, field_set)
    end
end

class CrontabDayField < AbstractCrontabField
    MIN = 1
    MAX = 31
    FIELD = "day of month"
    def initialize(field_str, field_set)
        super(field_str, field_set)
    end
end

class CrontabMonthField < AbstractCrontabField
    MIN = 1
    MAX = 12
    FIELD = "month"
    def initialize(field_str, field_set)
        super(field_str, field_set)
    end
end

class CrontabWeekdayField < AbstractCrontabField
    MIN = 0
    MAX = 7
    FIELD = "day of week"
    def initialize(field_str, field_set)
        super(field_str, field_set)
    end
end

class InternalTime
    attr_accessor :year, :month, :day, :hour, :min

    def initialize(time)
        @year = time.year
        @month = time.month
        @day = time.day
        @hour = time.hour
        @min = time.min
    end

    def to_time
        Time.local(@year, @month, @day, @hour, @min, 0)
    end

    def inspect
        [year, month, day, hour, min].inspect
    end
end

class CrontabParserBase
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

class CrontabParser < CrontabParserBase

    cron_attr :minute
    cron_attr :hour
    cron_attr :day
    cron_attr :month
    cron_attr :weekday

    MINUTE_INDEX = 0
    HOUR_INDEX = 1
    DAY_INDEX = 2
    MONTH_INDEX = 3
    WEEKDAY_INDEX = 4

    CRONTAB_FIELD_REGEXP = Regexp.new('^(\d+)(-(\d+)(/(\d+))?)?$')
    CRONTAB_FIELD_START_GROUP_NUM = 1
    CRONTAB_FIELD_STOP_GROUP_NUM = 3
    CRONTAB_FIELD_STEP_GROUP_NUM = 5


    def initialize(str)
        case str
        when String
            fields = str.split(/\s+/)
            length = fields.length
            raise InvalidCrontabError, "#{str} does not match crontab trigger pattern" unless length == 5
            self.minute = fields[MINUTE_INDEX]
            self.hour = fields[HOUR_INDEX]
            self.day = fields[DAY_INDEX]
            self.month = fields[MONTH_INDEX]
            self.weekday = fields[WEEKDAY_INDEX]
        else
            raise ArgumentError, "invalid string is received"
        end
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
        puts "symbol = #{symbol}"
        min = get_field_class(symbol)::MIN
        max = get_field_class(symbol)::MAX
        max_range = min..max
        converted_value = value.gsub(/^\*/, "#{min}-#{max}")
        field_set = converted_value.split(',').map do |sub_val|
            matched = CRONTAB_FIELD_REGEXP.match(sub_val)
            if matched
                start = matched[CRONTAB_FIELD_START_GROUP_NUM]
                stop = matched[CRONTAB_FIELD_STOP_GROUP_NUM]
                step = matched[CRONTAB_FIELD_STEP_GROUP_NUM]
                start = start.to_i
                stop = stop.nil? ? start : stop.to_i
                step = step.nil? ? 1 : step.to_i
                unless range_check(start, stop, step, max_range)
                    raise raise InvalidCrontabError, "invalid #{symbol} field => #{value}"
                end
                stepped_range(start..stop, step)
            else
                raise InvalidCrontabError, "invalid #{symbol} field => #{value}"
            end
        end.flatten.sort.to_set

        p field_set
        instance_variable_set("@#{symbol}", get_field_class(symbol).new(value, field_set))
    end

    def range_check(start, stop, step, max_range)
        max_range.include?(start) && max_range.include?(stop) && max_range.include?(step) ? true : false
    end

    def stepped_range(allowed_range, step)
        last = allowed_range.last
        first = allowed_range.first

        return [first] if first == last && step == 1
        len = last - first

        num = len.div(step)
        result = (0..num).map { |i| first + step * i }

        result.pop if result[-1] == last and allowed_range.exclude_end?
        result
    end

    def next
        t = InternalTime.new(Time.now)

        unless self.month.field_set.include?(t.month)
            nudge_month(t)
            t.day = 0
        end

        unless interpolate_weekdays(t.year, t.month).include?(t.day)
            nudge_date(t)
            t.hour = -1
        end

        unless self.hour.field_set.include?(t.hour)
            nudge_hour(t)
            t.min = -1
        end

        # always nudge the minute
        nudge_minute(t)
        t = t.to_time
        t
    end

    def last
        t = InternalTime.new(Time.now)

        unless self.month.field_set.include?(t.month)
            nudge_month(t, :last)
            t.day = 32
        end

        if t.day == 32 || !interpolate_weekdays(t.year, t.month).include?(t.day)
            nudge_date(t, :last)
            t.hour = 24
        end

        unless self.hour.field_set.include?(t.hour)
            nudge_hour(t, :last)
            t.min = 60
        end

        # always nudge the minute
        nudge_minute(t, :last)
        t = t.to_time
        t
    end

    # returns a list of days which do both match self.day or self.weekday
    def interpolate_weekdays(year, month)
        @_interpolate_weekdays_cache ||= {}
        @_interpolate_weekdays_cache["#{year}-#{month}"] ||= interpolate_weekdays_without_cache(year, month)
    end

    def interpolate_weekdays_without_cache(year, month)
        t = Date.new(year, month, 1)
        valid_mday = self.day.field_set
        valid_wday = self.weekday.field_set

        # Careful: crontabs may use either 0 or 7 for Sunday:
        valid_wday << 0 if valid_wday.include?(7)

        result = []
        while t.month == month
            result << t.mday if valid_mday.include?(t.mday) || valid_wday.include?(t.wday)
            t = t.succ
        end

        result.to_set
    end

    def nudge_year(t, dir = :next)
        t.year = t.year + (dir == :next ? 1 : -1)
    end

    def nudge_month(t, dir = :next)
        field_set = self.month.field_set
        next_value = find_best_next(t.month, field_set, dir)
        t.month = next_value || (dir == :next ? field_set.first : field_set.last)

        nudge_year(t, dir) if next_value.nil?

        # we changed the month, so its likely that the date is incorrect now
        valid_days = interpolate_weekdays(t.year, t.month)
        t.day = dir == :next ? valid_days.first : valid_days.last
    end

    def date_valid?(t, dir = :next)
        interpolate_weekdays(t.year, t.month).include?(t.day)
    end

    def nudge_date(t, dir = :next, can_nudge_month = true)
        field_set = interpolate_weekdays(t.year, t.month)
        next_value = find_best_next(t.day, field_set, dir)
        t.day = next_value || (dir == :next ? field_set.first : field_set.last)

        nudge_month(t, dir) if next_value.nil? && can_nudge_month
    end

    def nudge_hour(t, dir = :next)
        field_set = self.hour.field_set
        next_value = find_best_next(t.hour, field_set, dir)
        t.hour = next_value || (dir == :next ? field_set.first : field_set.last)

        nudge_date(t, dir) if next_value.nil?
    end

    def nudge_minute(t, dir = :next)
        field_set = self.minute.field_set
        next_value = find_best_next(t.min, field_set, dir)
        t.min = next_value || (dir == :next ? field_set.first : field_set.last)

        nudge_hour(t, dir) if next_value.nil?
    end

    # returns the smallest element from allowed which is greater than current
    # returns nil if no matching value was found
    def find_best_next(current, allowed, dir)
        if dir == :next
            allowed.sort.find { |val| val > current }
        else
            allowed.sort.reverse.find { |val| val < current }
        end
    end

    def show
        puts "verify success"
        # puts "minute = #{self.minute}, hour = #{self.hour}, day = #{self.day}, month = #{self.month}, weekday = #{self.weekday}"
    end
end


test_crontab_str = lambda do |str, expect|
    begin
        puts "=================================================================="
        puts "check for #{str}, expect result '#{expect}'"
        parser = CrontabParser.new(str)
        puts "#{parser.next}"
        # parser.show
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
test_crontab_str.call("*/2 5-10 8-20/6 6,2,1,5,3 *", "wrong")   # wrong
