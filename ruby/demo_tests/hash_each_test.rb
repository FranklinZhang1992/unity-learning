hash = {}

sub_hash1 = {}
id1 = "1"
value1 = "111"
sub_hash1[:id] = id1
sub_hash1[:value] = value1
hash[id1] = sub_hash1

sub_hash2 = {}
id2 = "2"
value2 = "222"
sub_hash2[:id] = id2
sub_hash2[:value] = value2
hash[id2] = sub_hash2

hash.each { |id, value|
  puts "id => #{id}, value => #{value}"
}
