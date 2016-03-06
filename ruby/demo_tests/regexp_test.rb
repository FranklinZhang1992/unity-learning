SAMBA_FOLDER = "^//(\\d{1,3}[.]){3}\\d{1,3}/\\S*$"
LINUX_FOLDER = "^/\\S*$"
WINDOWS_FOLDER = "^[A-Z]:\\\\S*$"
MANAGED_FOLDER = "^(\\S*)[【](\\d+)[】]$"

def match_test(type, str)
  puts "match for #{str}"
  regexp_str = nil
  case type
  when "samba"
    regexp_str = SAMBA_FOLDER
  when "linux"
    regexp_str = LINUX_FOLDER
  when "windows"
    regexp_str = WINDOWS_FOLDER
  when "folder"
    regexp_str = MANAGED_FOLDER
  end
  regexp_str or raise "Unknown type #{type}"
  if str.match(Regexp.new(regexp_str))
    puts "yes"
  else
    puts "no"
  end
end

def match_samba_folder(str)
  match_test("samba", str)
end

def match_linux_folder(str)
  match_test("linux", str)
end

def match_windows_folder(str)
  match_test("windows", str)
end

def match_folder(str)
  match_test("folder", str)
end

def format_folder_name(old_name, num)
  result = old_name.match(Regexp.new(MANAGED_FOLDER))
  new_name = nil
  if result
    file_name = result[1]
    origin_num = result[2]
    new_name = "#{file_name}【#{num}】"
  else
    new_name = "#{old_name}【#{num}】"
  end
  if new_name != old_name
    puts "Rename #{old_name} to #{new_name}"
  end
  puts "old name is #{old_name}, new name is #{new_name}"
end

# match_linux_folder("/tmp")
# match_windows_folder("E:\\")
# match_folder("c【2】")
# match_folder("c")

format_folder_name("c", 1)
format_folder_name("c【2】", 2)
format_folder_name("c【2】", 3)
