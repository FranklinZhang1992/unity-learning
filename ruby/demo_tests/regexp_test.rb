# encoding: utf-8
SAMBA_FOLDER = "^//(\\d{1,3}[.]){3}\\d{1,3}/\\S*$"
SAMBA_FILE = "^//(\\d{1,3}[.]){3}\\d{1,3}/\\S*[\\.][iI][sS][oO]$"
NFS_FOLDER = "^(\\d{1,3}[.]){3}\\d{1,3}[:]/\\S*$"
NFS_FILE = "^(\\d{1,3}[.]){3}\\d{1,3}[:]/\\S*[\\.][iI][sS][oO]$"
LINUX_FOLDER = "^/\\S*$"
WINDOWS_FOLDER = "^[A-Z]:\\\\S*$"
MANAGED_FOLDER = "^(\\S*)[【](\\d+)[】]$"
ISO_FILE = '^\S*[\.][iI][sS][oO]$'

def match_test(type, str)
  puts "match for #{str}"
  regexp_str = nil
  case type
  when "samba"
    regexp_str = SAMBA_FOLDER
  when "nfs"
    regexp_str = NFS_FOLDER
  when "linux"
    regexp_str = LINUX_FOLDER
  when "windows"
    regexp_str = WINDOWS_FOLDER
  when "folder"
    regexp_str = MANAGED_FOLDER
  when "smbfile"
    regexp_str = SAMBA_FILE
  when "nfsfile"
    regexp_str = NFS_FILE
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

def match_nfs_folder(str)
  match_test("nfs", str)
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

def match_samba_file(str)
  match_test("smbfile", str)
end

def match_nfs_file(str)
  match_test("nfsfile", str)
end

def iso?(url)
  return url.match(Regexp.new(ISO_FILE))
end

def match_domain_name(str)
  puts "match for #{str}"
  result = str.match(Regexp.new('^(?:([^:/?#.]+):)?' + # scheme
                                '(?://(?:([^/?#]*)@)?' + # userinfo
                                '([\\w\\d\\u0100-\\uffff\\-.%]*)' + # domain
                                '(?::([0-9]+))?)?' + # port
                                '([^?#]+)?' + # path
                                '(?:\\?([^#]*))?' + # query
                                '(?:#(.*))?$' # fragment
                                ))
  if result.nil?
    puts "not match"
  else
    p result
  end
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

def fetch_remote_iso(full_path)
  result = full_path.match(Regexp.new('^([\S]*)/([\S]*[\.]iso)$'))
  raise "not a valie url #{full_path}" if result.nil?
  folder = result[1]
  file = result[2]
  other = result[3]
  puts "other is nil" if other.nil?
  puts "folder = #{folder}, file = #{file}, other = #{other}"
end

def check_make_finished
  workspace = "workspace5"
  original_str = "make[1]: Leaving directory `/developer/fzhang/workspace5/unity-stratus/upgrade'"
  pattern = Regexp.new("make\\[1\\]: Leaving directory \\`/developer/fzhang/#{workspace}/unity-stratus/upgrade")
  # if original_str.match(pattern)
  #   puts "yes"
  # else
  #   puts "no"
  # end

  file = "../logs/make.out"
  File.open(file) { |f|
    while line = f.gets
      line.chomp!
      if line.match(pattern)
        puts "build finished"
        break
      end
    end
  }
end

def check_dut_reserve
  pattern = Regexp.new('Reserved:[ ]([a-zA-Z]*)[ ]at')
  str1 = "patmos         0% DUT Rel>=4.0 Vms<=6 esp ivyBridge model_r610 processor_westmere rack_4b raid sc_perc_6i simplexboot sn sub1080 vendor_dell vlanFault Idle"
  str2 = "caltech        0% DUT Rel>=2.1.2 Vms<=10 esp idrac model_r710 multiNic processor_westmere rack_6a sc_perc_6i sn sub1080 vendor_dell vlanFault westmere Reserved: jalberna at 21-Mar 10:25; FAILED IMAGE of DUT (check physical nodes, possibly known Power or BMC Issue) (AUTO), overnight"
  result1 = str1.match(pattern)
  result2 = str2.match(pattern)
  if result1
    puts "dut patmos is reserved by \"#{result1[1]}\""
  else
    puts "dut patmos is not reserved"
  end
  if result2
    puts "dut caltech is reserved by \"#{result2[1]}\""
  else
    puts "dut caltech is not reserved"
  end
end

# match_linux_folder("/tmp")
# match_windows_folder("E:\\")
# match_folder("c【2】")
# match_folder("c")

# format_folder_name("c", 1)
# format_folder_name("c【2】", 2)
# format_folder_name("c【2】", 3)
# p iso?("abc.iso")
# p iso?("abciso")
# p iso?("//134.111.31.228/Users/TEST/p2v/en_windows_server_2008_with_sp2_x64_dvd_342336.iso")
# fetch_remote_iso("//134.111.31.228/Users/TEST/p2v/en_windows_server_2008_with_sp2_x64_dvd_342336.iso")

# match_nfs_folder("134.111.24.224:/developer/fzhang/my-pool")
# match_nfs_folder("134.111.24.224/developer/fzhang/my-pool")
# match_nfs_folder("//134.111.24.224:/developer/fzhang/my-pool")

# match_samba_file("//134.111.31.228/Users/TEST/p2v/en_windows_server_2008_with_sp2_x64_dvd_342336.iso")
# match_samba_file("//134.111.31.228/Users/TEST/p2v/en_windows_server_2008_with_sp2_x64_dvd_342336.ISO")
# match_samba_file("134.111.31.228/Users/TEST/p2v/en_windows_server_2008_with_sp2_x64_dvd_342336.iso")
# match_samba_file("134.111.31.228:/Users/TEST/p2v/en_windows_server_2008_with_sp2_x64_dvd_342336.iso")
# match_nfs_file("134.111.24.224:/developer/fzhang/my-pool/en_windows_7_home_premium_with_sp1_x64_dvd_u_676549.iso")
# match_nfs_file("134.111.24.224:/developer/fzhang/my-pool/en_windows_7_home_premium_with_sp1_x64_dvd_u_676549.ISO")
# match_nfs_file("134.111.24.224/developer/fzhang/my-pool/en_windows_7_home_premium_with_sp1_x64_dvd_u_676549.iso")
# match_nfs_file("//134.111.24.224/developer/fzhang/my-pool/en_windows_7_home_premium_with_sp1_x64_dvd_u_676549.iso")

# match_domain_name("github.com")
# match_domain_name("wwww.baidu.com")
# match_domain_name("www.firefox.com.cn")
# match_domain_name("a.b.c.d.e")
# match_domain_name("//a.b.c.d.e/abc")
# match_domain_name("//a.b.c.中国.e.f:8080/abc")
# match_domain_name("//a.b&.c.d.e.f:80/abc/123")

# check_make_finished

check_dut_reserve
