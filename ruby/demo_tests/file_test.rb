# encoding: utf-8
require "fileutils"

# if File.exists?('test.txt')
# 	puts "file already exists"
# elsif
# 	FileUtils.touch('test.txt')
# end

# dir = ''

# subdir = 'test'

# path = File.join(dir, subdir)
# Dir.mkdir(path)

  def scan_folder(folder)
    puts "scan #{folder}"
     Dir.foreach(folder) { |x|
      next if  x == "." || x == ".."
      # Only deal with the first level
      if File::directory?(File.join(folder, x))
        file_num = 0
        puts "path is #{File.join(folder, x)}"
        Dir.foreach(File.join(folder, x)) { |file|
          next if  file == "." || file == ".."
          puts file
          file_num += 1
        }
        puts "count is #{file_num}"
        old_name = x.to_s
        new_name = "#{old_name}【#{file_num}】"
        puts old_name
        puts new_name
        File.rename(File.join(folder, old_name), File.join(folder, new_name))
      end
     }
  end
  # scan_folder("/mnt/point")
  def exist?(path)
    result = File.exist?(path)
    if result
      puts "File #{path} exists"
    else
      puts "File #{path} does not exist"
    end
  end

exist?("/tmp/test")
exist?("/tmp/test_file")
