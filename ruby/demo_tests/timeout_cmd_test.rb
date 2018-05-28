require 'timeout'

class Test
    SCRIPT = "/tmp/time_last_script.sh"
    def gen_test_script
        script_content =<<EOF
#!/bin/bash

START_TIME=`date +%s`
DEST_TIME=`expr $START_TIME + 10`
echo $START_TIME
echo $DEST_TIME
while [ $START_TIME -lt $DEST_TIME ]
do
  echo "[$START_TIME] waiting"
  START_TIME=`date +%s`
  sleep 1
done
EOF
        File.open(SCRIPT, "w") do |file|
            file.puts script_content
        end
        %x{chmod +x #{SCRIPT}}
    end

    def delete_test_script
        File.delete(SCRIPT)
    end

    def test_A
        output = timeout(2) { %x{#{SCRIPT}} }
        puts "execute script done"
    rescue Timeout::Error => err
        puts "Timeout running script (#{err})"
    end

    def run
        gen_test_script
        test_A
        delete_test_script
    end
end

t = Test.new
t.run
