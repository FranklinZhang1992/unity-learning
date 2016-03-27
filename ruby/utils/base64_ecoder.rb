require 'base64'

class Encoder
  attr_accessor :content
  attr_accessor :input_file
  attr_accessor :output_file
  def load(file_path)
    file_content = ""
    File.open(file_path,"r") do |file|
      while line  = file.gets
        line.chomp!
        file_content += "#{line}" unless line == ""
      end
    end # end of file block
    self.content = file_content
  end
  def dump(file_path)
    File.delete(file_path) if File.exist?(file_path)
    File.open(file_path, "a") { |file|
      file.write self.content
    }
  end
  def decode
    self.content = Base64.decode64(self.content)
    puts "decode success"
  end
  def encode
    self.content = Base64.encode64(self.content)
    puts "encode success"
  end
end

begin
  puts "Please type input file path:"
  input_file = gets.chomp!
  raise "input file is required" if input_file == ""
  raise "input file does not exist" unless File.exist?(input_file)
  puts "Please type output file path:"
  output_file = gets.chomp!
  raise "output file is required" if output_file == ""
  raise "output file does not exist" unless File.exist?(output_file)
  encoder = Encoder.new
  encoder.load(input_file)
  encoder.decode
  encoder.dump(output_file)
rescue Exception => e
  puts "error: #{e}"
end
