require 'singleton'
require 'rexml/document'

class CacheManager
    include Singleton
    include REXML

    def initialize
        @employee_lock = Monitor.new
    end

    def mock_delay
        sleep 1
    end

    def read_file
        content =<<EOT
<root>
    <employee>
        <id>EP-001</id>
        <name>Mike</name>
        <phone>123456</phone>
    </employee>
    <guest>
        <name>Tom</name>
        <phone>654321</phone>
    </guest>
</root>
EOT
        mock_delay
        Document.new(content).root
    end

    def employee_cache_expired?
        puts "@e_lupt = #{@e_lupt}, now = #{Time.now.to_i}"
        @e_lupt.nil? || Time.now.to_i - @e_lupt > 3
    end

    def employee_cache
        return @employee_cache unless employee_cache_expired?
        nil
    end

    def get_employee
        content = employee_cache
        if content.nil?
            @employee_lock.synchronize {
                content = employee_cache
                if content.nil?
                    content = read_file
                    @employee_cache = content
                    @e_lupt = Time.now.to_i
                    puts "#{Time.now} Get employee from file"
                else
                    puts "#{Time.now} Get employee from cache (2)"
                end
            }
        else
            puts "#{Time.now} Get employee from cache (1)"
        end
        content
    end
end

cm = CacheManager.instance
t_arr = []
(0...10).each do
    t_arr << Thread.new {cm.get_employee}
end

t_arr.each do |t|
    t.join
end
