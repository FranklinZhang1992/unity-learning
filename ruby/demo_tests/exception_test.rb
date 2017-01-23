class CustomError < RuntimeError
    attr :default, :key, :param

    def initialize(default, key, param=[])
        super(default)
        @default = default
        @key = key
        @param = param.nil? ? [] : param
    end
end

begin
    raise CustomError.new("default message", "DEFAULT", ["a", "b", "c"])
rescue Exception => err
    puts "message: #{err.message}"
    backtrace = err.backtrace.join("\n")
    puts "backtrace: #{backtrace}"
    puts "default: #{err.default}"
    puts "key: #{err.key}"
    puts "param: #{err.param}"
end
