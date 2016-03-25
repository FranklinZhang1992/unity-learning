path = "api/domain/id/1001"
# p path
# p path.sub(path, '')
# p path.sub(path, '').split('/')

# str = "<table>abc</table>"
# begin_index = str.index('<table>')
# end_index = str.index('</table>')
# puts "begin = #{begin_index}, end = #{end_index}"
# p str[begin_index, end_index - begin_index + 8]

# data = "<a href=\"http://australia.sn.stratus.com\" target=_blank><a href=\"http://australia.sn.stratus.com\" target=_blank>"
# data1 = data.gsub('target=_blank', 'target="_blank"')
# p data
# p data1

str1 = "abc<a href=\"release.py?dut=qa152nh&user=jryan\" onclick=\"return confirm('Are you sure you want to release DUT qa152nh ?');\"/>37</a>abc"
str2 = "abc<a href=\"release.py?dut=greece&user=service\" onclick=\"return confirm('Are you sure you want to release DUT greece ?');\"/>??</a>abc"
# /<a href=\S* onclick="return confirm\('Are you sure you want to release DUT [a-z]{1,} \?'\);"\/>[0-9]*<\/a>/
pattern = Regexp.new(/<a href=\S* onclick="return confirm\('Are you sure you want to release DUT [0-9a-zA-Z]{1,} \?'\);"\/>[0-9\?]*<\/a>/)
result = str2.match(pattern)
if result
  puts "yes => #{result}"
else
  puts "no"
end
# str = str.gsub(/<a href=\S* onclick="return confirm\('Are you sure you want to release DUT [a-z]{1,} \?'\);"\/>[0-9]*<\/a>/, '')
# p str

# str = "<td class=\"idle\">idle</td><td class=\"idle\">10g Rel>=4.0 Vms<=40 biz10g dr drbd8 esp ivyBridge model_r720 multiNic processor_ivyBridge rack_8b raid san sc_perc_h710 sn sub1080 vendor_dell</td>"
# # /<td class="idle">[a-zA-Z0-9 ]*<=*[a-zA-Z ]<\/td>/
# pattern = Regexp.new(/<td class="idle">[\S\s]*Vms/)
# result = str.match(pattern)
# if result
#   puts "yes"
#   p result
# else
#   puts "no"
# end
