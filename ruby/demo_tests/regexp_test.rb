# encoding: utf-8
SAMBA_FOLDER = "^//(\\d{1,3}[.]){3}\\d{1,3}/\\S*$"
SAMBA_FILE = "^//(\\d{1,3}[.]){3}\\d{1,3}/\\S*[\\.][iI][sS][oO]$"
NFS_FOLDER = "^(\\d{1,3}[.]){3}\\d{1,3}[:]/\\S*$"
NFS_FILE = "^(\\d{1,3}[.]){3}\\d{1,3}[:]/\\S*[\\.][iI][sS][oO]$"
LINUX_FOLDER = "^/\\S*$"
WINDOWS_FOLDER = "^[A-Z]:\\\\S*$"
MANAGED_FOLDER = "^(\\S*)[【](\\d+)[】]$"
ISO_FILE = '^\S*[\.][iI][sS][oO]$'
WIN_2K12_REGEXP = 'win\S*2[0-9a-zA-Z]{0,}12'
VALID_VERSION_REGEXP = Regexp.new('[0-9][.][0-9]')
VIRTUAL_SIZE_REGEXP = Regexp.new("virtual\\s+size:\\s+\\S+[A-Z]\\s+\\(([0-9]+)\\s+bytes\\)")
def valid_version_re() VALID_VERSION_REGEXP end
VALID_RELEASE_NUM_REGEXP = Regexp.new('[0-9]{1,}')
def valid_release_num_re() VALID_RELEASE_NUM_REGEXP end

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

def check_for_win2k12(name)
  pattern = Regexp.new(WIN_2K12_REGEXP)
  if name.match(pattern)
    puts "#{name} is win2k12"
  else
    puts "#{name} is not win2k12"
  end
end

def match_os(str)
  puts "match for #{str}"
  pattern = Regexp.new('CentOS [\S ]* 7.2')
  if str.match(pattern)
    puts "yes"
  else
    puts "no"
  end
end

def match_version(version)
  if version.match(valid_version_re)
    puts "yes"
  else
    puts "no"
  end
end

def match_release_num(release_num)
  if release_num.match(valid_release_num_re)
    puts "yes"
  else
    puts "no"
  end
end

def divide_dut_ver(dut_ver)
  puts "divide for #{dut_ver}"
  pattern = Regexp.new('([0-9]{1,})[.]([0-9]{1,})[.][0-9]{1,}[-]([0-9]{1,})')
  result = dut_ver.match(pattern)
  if result
    num1 = result[1] || "0"
    num2 = result[2] || "0"
    num3 = result[3] || "0"
    num1 = num1.to_i
    num2 = num2.to_i
    num3 = num3.to_i
    p num1
    p num2
    p num3
  else
    puts "no"
  end
end

def match_version(str)
  puts "match for #{str}"
  pattern = Regexp.new('7[.]4[.][0-9][.][0-9]-[0-9]{1,}')
  result = str.match(pattern)
  if result
    puts "yes"
    p result
  else
    puts "no"
  end
end

def match_virtual_size(str)
  puts "match for #{str}"
  result = str.match(VIRTUAL_SIZE_REGEXP)
  if result
    puts "match"
  else
    puts "not match"
  end
end

def ignore_case
  pattern = Regexp.new('abc', true)
  p pattern.match("abc")
  p pattern.match("ABC")
end

ignore_case
