# count1 = count2 = 0
# difference = 0
# counter = Thread.new do
# 	puts "counter thread"
# 	loop do
# 		count1 += 1
# 		count2 += 1
# 	end
# end
# spy = Thread.new do
# 	puts "spy thread"
# 	loop do
# 		difference += (count1 - count2).abs
# 	end
# end
# sleep 1
# puts "count1 : #{count1}"
# puts "count2 : #{count2}"
# puts "difference : #{difference}"

class Demo
	def initialize
		@count = 0
		@ready = false
	end
	def ready?
		@ready
	end
	def process
		puts "process"
	end
	def inc
		puts "count = #{@count}"
		@count += 1
		if @count == 3
			@ready = true
		end
	end
	def start
		# process until ready? unless ready?

		# inc until ready? unless ready?
		@thread = Thread.new do
			begin
				puts "new thread"
				@ready = true
			rescue Exception => e
				puts "Exception => #{e}"
			end
		end
		# sleep(1) until ready? unless ready?
		puts "ready"
	end
end
demo = Demo.new
demo.start

	