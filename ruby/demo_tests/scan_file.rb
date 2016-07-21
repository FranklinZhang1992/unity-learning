file = ARGV[0].chomp
result = %x{cat #{file} 2>&1}
if $?.success?
  if result.match(Regexp.new("cdrom"))
    puts "yes"
  end
end
