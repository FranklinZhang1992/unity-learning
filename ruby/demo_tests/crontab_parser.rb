#!/usr/bin/ruby

class InvalidCrontabError < RuntimeError ; end

class AbstractCrontabField
    attr :field_str
    attr :time_set

    def initialize(field_str, time_set)
        @field_str = field_str
        case data
        when Set
            @time_set = time_set
        else
            raise ArgumentError, "invalid set is received"
        end
    end

    def to_s
        "#{self.field_str}"
    end

    def to_set
        self.time_set
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

    MINUTE_GROUP_NUM = 0
    HOUR_GROUP_NUM = 1
    DAY_GROUP_NUM = 2
    MONTH_GROUP_NUM = 3
    WEEKDAY_GROUP_NUM = 4

    def initialize(str)
        case str
        when String
            fields = str.split(/\s+/)
            length = fields.length
            raise InvalidCrontabError, "#{str} does not match crontab trigger pattern" unless length == 5
            self.minute = fields[MINUTE_GROUP_NUM]
            self.hour = fields[HOUR_GROUP_NUM]
            self.day = fields[DAY_GROUP_NUM]
            self.month = fields[MONTH_GROUP_NUM]
            self.weekday = fields[WEEKDAY_GROUP_NUM]
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
        
        instance_variable_set("@#{symbol}", get_field_class(symbol).new(value))
    end

end

parser = CrontabParser.new
parser.parse_crontab_str(1)
