class Domain
	def init
		@table = Hash.new
		@table['creating'] = lambda { |vm_state|
			puts vm_state
			puts 'test1'
		}
		@table['stopping'] = lambda { |vm_state| 
			puts vm_state 
			puts 'test'
		}
	end
	def proc(param)
		handler = @table[param]
		if handler.nil?
			puts 'nil'
		else
			puts 'not nil'
			# p handler
			handler.call(param)
		end
	end
end

dom = Domain.new
dom.init
dom.proc('creating')
dom.proc('stopping')