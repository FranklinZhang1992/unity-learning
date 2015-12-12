def do_event
	puts "Get signal"
end

trap("INT") {
	do_event
}
while true
	puts "processing"
	sleep 1
end