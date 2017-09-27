def valid_path?(path)
    !path.nil? && !path.lstrip.rstrip.empty?
end

path = nil
puts "#{path}: #{valid_path?(path)}"
path = " "
puts "#{path}: #{valid_path?(path)}"
path = "  "
puts "#{path}: #{valid_path?(path)}"
path = "a  "
puts "#{path}: #{valid_path?(path)}"
