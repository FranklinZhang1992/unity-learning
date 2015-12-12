require './pons'

	SuperNova.pons().boot
	trap("INT") { SuperNova.pons().stop }
	SuperNova.pons().start


# array = Array.new
# array << "1"
# array << "2"

# result = array.detect { |value|
# 	value == "1"
# }
# p result