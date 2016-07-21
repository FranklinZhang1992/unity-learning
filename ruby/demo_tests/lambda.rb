class Domain
  def init
    @table = Hash.new
    @table[:creating] = lambda { |vm_state|
      puts vm_state
      puts 'test1'
    }
    @table[:stopping] = lambda { |vm_state|
      puts vm_state 
      puts 'test'
    }
    @table[:starting] = lambda { |vm_state|
      case vm_state
      when 'running'
        handle_running_in_starting
      when 'starting'
        # Do nothing
      end
    }
  end
  def handle_running_in_starting
    puts "handle_running_in_starting"
  end
  def proc(param, param2)
    handler = @table[param]
    if handler.nil?
      puts 'nil'
    else
      puts 'not nil'
      p handler
      handler.call(param2)
    end
  end
end

dom = Domain.new
dom.init
# dom.proc(:creating)
# dom.proc(:stopping)
dom.proc(:starting, 'running')
