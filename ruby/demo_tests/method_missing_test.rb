class PhantomService
	def call_remote_method(symbol, *args)
		puts "call remote"
		p symbol
		p args
	end
	alias :method_missing :call_remote_method
end

ps = PhantomService.new
ps.create_local_image_container