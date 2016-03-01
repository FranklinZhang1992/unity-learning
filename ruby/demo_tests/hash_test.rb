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
# puts handler.key

def device(storage, params={})
  puts "nil" if storage.nil? && params.nil? || params.length == 0
  puts "device"
end

def main
  device(nil, nil)
  params = {}
  storage = "test"
  device(nil, params)
  device(storage, params)
  params[:boot] = true
  device(storage, params)
  device(nil, params)
end

main
