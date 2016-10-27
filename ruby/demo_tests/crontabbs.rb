require 'set'
require 'rexml/document'
require 'singleton'
include REXML

class CronJob
    attr :id
    attr :schedule
    attr :command

    def set_properties(id, schedule, command)
        @id = id
        @schedule = schedule
        @command = command
    end

    def put(xml)
        @id = begin xml.elements['id'].text rescue nil end
        @schedule = begin xml.elements['schedule'].text rescue nil end
        @command = begin xml.elements['command'].text rescue nil end
    end

    def to_xml_string
        xml_string = "<crontab>"
        xml_string << "<id>" << self.id.to_s << "</id>"
        xml_string << "<schedule>" << self.schedule.to_s << "</schedule>"
        xml_string << "<command>" << self.command.to_s << "</command>"
        xml_string << "</crontab>"
    end

    def to_xml
        Document.new(to_xml_string).root
    end

    def get_string
        to_xml_string
    end
end

class CronManager
    include Singleton

    CRON_CONFIG_FILE = "/tmp/cron.cron"
    SCHEDULE_REGEXP = Regexp.new('([\*/\-,0-9] [\*/\-,0-9] [\*/\-,0-9] [\*/\-,0-9] [\*/\-,0-9]) ([\S ]*)')
    SCHEDULE_ID_REGEXP = Regexp.new('id = ([a-zA-z0-9\-]{36})')
    def schedule_re() SCHEDULE_REGEXP end
    def schedule_id_re() SCHEDULE_ID_REGEXP end

    def each() @cron_jobs.each { |cron_job| yield cron_job } end

    def initialize
        @cron_jobs = []
    end

    # def create
    #   @cron_jobs.clear
    #   cron_config_file = "/tmp/cron.cron"
    #   unless File.exist?(cron_config_file)
    #     cron_job1 = "* * * * * echo \"for test1\" >> /tmp/test.out"
    #     cron_job2 = "* * * * * echo \"for test2\" >> /tmp/test.out"
    #     cron_job3 = "* * * * * echo \"for test3\" >> /tmp/test.out"
    #     File.open(cron_config_file, 'w+') do |output|
    #       output.puts cron_job1
    #       output.puts cron_job2
    #       output.puts cron_job3
    #     end
    #   end
    #   %x{crontab #{cron_config_file}}
    #   cj1 = CronJob.new
    #   cj1.put("* * * * *", "echo \"for test1\" >> /tmp/test.out")
    #   cj2 = CronJob.new
    #   cj2.put("* * * * *", "echo \"for test2\" >> /tmp/test.out")
    #   cj3 = CronJob.new
    #   cj3.put("* * * * *", "echo \"for test3\" >> /tmp/test.out")
    #   cj4 = CronJob.new
    #   cj4.put("* * * * *", "echo \"for test4\" >> /tmp/test.out")
    #   @cron_jobs << cj1
    #   @cron_jobs << cj2
    #   @cron_jobs << cj3
    #   @cron_jobs << cj4
    # end

    def create(xml)
        load_cron_jobs
        cron_job = CronJob.new
        cron_job.put(xml)
        @cron_jobs << cron_job
        # puts "cron.create @cron_jobs = #{@cron_jobs}"
        File.open(CRON_CONFIG_FILE, 'w+') do |output|
            @cron_jobs.each do |cron_job|
                job = "#{cron_job.schedule} #{cron_job.command}"
                output.puts job
            end
        end

        %x{crontab #{CRON_CONFIG_FILE}}
        %x{rm -f #{CRON_CONFIG_FILE}}
        to_xml
    end

    def delete(xml)
        load_cron_jobs
    end

    def load_cron_jobs
        @cron_jobs.clear
        user_name = %x{whoami}.chomp
        cron_file = "/var/spool/cron/#{user_name}"
        if File.exist?(cron_file)
            result = %x{crontab -l}
            result.each_line do | line |
                match_schedule = schedule_re.match(line)
                if match_schedule
                    schedule = match_schedule[1]
                    command = match_schedule[2]
                    puts "line = #{line}"
                    match_id = schedule_id_re.match(line)
                    id = match_id[1] if match_id
                    cron_job = CronJob.new
                    cron_job.set_properties(id, schedule, command)
                    @cron_jobs << cron_job
                end
            end # end of result block
        end
    end

    def show(flag)
        puts "======#{flag}========"
        @cron_jobs.each do |cron_job|
            puts "cron_job: #{cron_job.schedule}, #{cron_job.command}"
        end
    end

    def to_xml
        xml = Element.new('crontabs')
        load_cron_jobs
        each { |cron_job| xml << cron_job.to_xml }
        xml
    end

    def get_string
        xml_string = "<crontabs>"
        load_cron_jobs
        each { |cron_job| xml_string << cron_job.get_string }
        xml_string << "</crontabs>"
        xml_string
    end
end


begin
    a = "c2539a76-3f8a-4767-a87c-d4e8c0ab59f7"
    puts a.length
    cron_manager = CronManager.instance
    test_body1 = Document.new("<?xml version='1.0'?><create_crontab><id>1</id><schedule>* * * * *</schedule><command>echo \"id = c2539a76-3f8a-4767-a87c-d4e8c0ab59f7\" >> /tmp/test.out</command></create_crontab>").root
    test_body2 = Document.new("<?xml version='1.0'?><create_crontab><id>2</id><schedule>* * * * *</schedule><command>echo \"id = cfb03470-343d-4a5e-be66-50ab94a54a1f\" >> /tmp/test.out</command></create_crontab>").root
    result1 = cron_manager.create(test_body1)
    result2 = cron_manager.create(test_body2)
    puts result2
rescue Exception => e
    raise
end
