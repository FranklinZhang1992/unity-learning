class SendTest
	def hello(*args)
		puts "Hello " + args.join(' ')
	end
	def command(command, param)
		self.send(command, param)
	end
end

st = SendTest.new
st.command("hello", "Mike")