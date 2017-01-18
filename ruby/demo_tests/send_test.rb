require 'rexml/document'

include REXML

class SendTest

    attr_accessor :p1
    attr_accessor :p2

	def hello(*args)
		puts "Hello " + args.join(' ')
	end
	def command(command, param)
		self.send(command, param)
	end

    def set(xml)
        properties = {
            :p1 => { :default => self.p1, :convert => :to_s },
            :p2 => { :default => self.p2, :convert => :to_i }
        }

        empty = Element.new
        vals = {}
        properties.each { |prop, cfg|
            vals[prop] = ((xml.elements[prop.to_s]||empty).text || cfg[:default]).send(cfg[:convert])
        }

        puts "vals = #{vals}"
    end
end

st = SendTest.new
# st.command("hello", "Mike")
xml = Document.new('<set><p1>p1-value</p1><p2>5</p2></set>')
st.set(xml.root)
