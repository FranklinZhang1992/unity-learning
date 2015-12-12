class Domain
	def initialize(name1)
		@name = name1
	end
	def get_self
		p self.name
	end
	def action_self
		self.send("#{@name} self send")
	end
	def action
		send("#{@name} send")
	end
	def new_action
		self.send("#{@name} new send")
	end
	def send(message)
		puts message + " a"
	end
	def self.send(message)
		puts message + " b"
	end
end

domain1 = Domain.new("dom1")
# domain.get_self
domain1.action_self
domain1.action
domain1.new_action

domain2 = Domain.new("dom2")
domain2.action_self
domain2.action
domain2.new_action