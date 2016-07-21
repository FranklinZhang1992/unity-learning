def params
  params = {}
  params[:key] = "test"
  params[:password] = "passwd"
  params
end

def filter_hash(params_before_filter)
  puts "before filter: params => #{params_before_filter}"
  copied_params = {}
  params_before_filter.each_key do | key |
    if key == :password
      copied_params[key] = "******"
    else
      copied_params[key] = params_before_filter[key]
    end
  end
  puts "after filer:"
  puts "params => #{params_before_filter}"
  puts "copied_params => #{copied_params}"
end

def filter_args
  args = []
  args << "1234"
  args << :method
  args << params
  puts "before filter: args => #{args}"
  args.each do | arg |
    if arg.is_a? (Hash)
      filter_hash(arg)
    end
  end
end

# filter_hash
filter_args
