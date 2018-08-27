FILE_NAME = "test.tmp"
%x{touch #{FILE_NAME}}
file_stat = File.stat(FILE_NAME)
p file_stat.ino

%x{echo xxx > #{FILE_NAME}}
file_stat = File.stat(FILE_NAME)
p file_stat.ino
%x{rm -f #{FILE_NAME}}

%x{touch #{FILE_NAME}}
file_stat = File.stat(FILE_NAME)
p file_stat.ino
%x{rm -f #{FILE_NAME}}
