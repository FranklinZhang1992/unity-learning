module SuperNova
	class SysConfig
		FILENAME = "#{$ROOT_PATH}/opt/ft/cluster_ip"
		PROPS = [:name, :address, :cluster_uuid].to_set
		PROPS_STR = PROPS.inject(Set.new) { |s, prop| s << prop.to_s }
		PROPS.each { |prop| attr  prop, true}
		def initialize(props={})
			props.each_pair do |prop, val|
				self.send("#{prop}=", val) if PROPS.include? prop
			end
		end
		def self.props
			PROPS
		end
		def [](key)
			return nil unless PROPS.include? key
			self.send(key)
		end
		def write
			File.unlink(FILENAME) if File.exists?(FILENAME)
			File.open("#{FILENAME}.tmp", 'w') do |o|
				o.write(self.to_s)
			end
			File.rename("#{FILENAME}.tmp", FILENAME)
		end
		def read
			File.open(FILENAME, 'r').each_line do |line|
				prop_value = /^\s*(\S+)\s*=\s*(.*)$/.match(line) or next
				prop = prop_value[1].downcase
				val = prop_value[2]
				val = nil if val.empty?
				self.send("#{prop}=", val) if PROPS_STR.include? prop
			end
			self
		end
		def file?
			File.file?(FILENAME)
		end
	end
end
