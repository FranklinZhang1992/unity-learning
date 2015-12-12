require "fileutils"

# if File.exists?('test.txt')
# 	puts "file already exists"
# elsif 
# 	FileUtils.touch('test.txt')
# end

dir = ''

subdir = 'test'

path = File.join(dir, subdir)
Dir.mkdir(path)