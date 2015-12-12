require 'singleton'

class Base
	include Singleton
	@@count = 0
end

class C1 < Base
	def initialize
		@@count += 1
	end
	def get_count
		@@count
	end
end

class C2 < Base
	def initialize
		@@count += 1
	end
	def get_count
		@@count
	end
end

class C3 < Base
	def initialize
		@@count += 1
	end
	def get_count
		@@count
	end
end

c1 = C1.instance
c2 = C2.instance
c3 = C3.instance
p c1.get_count
p c2.get_count