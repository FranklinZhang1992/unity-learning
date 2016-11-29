begin
    %x{touch /tmp/a.tmp}
    puts File.file?("/tmp/a.tmp")
    puts File.file?("/tmp/b.tmp")
    %x{rm -f /tmp/a.tmp}
rescue Exception => e
    raise
end
