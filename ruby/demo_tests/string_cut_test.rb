str = "balalalal<begin>lulululuE"
begin_index = str.index('<begin>')
len = str.length - begin_index
puts "len = #{len}"
str = str[begin_index, len]
puts str
