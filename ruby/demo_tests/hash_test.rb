class Context
	def initialize(key)
		@key = key
	end
	def key
		@key
	end
end

CONTEXTS = Hash.new { |hash, key| hash[key] = Context.new(key) }

handler = CONTEXTS["mike"]
puts handler.key