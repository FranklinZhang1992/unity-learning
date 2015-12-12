require './syncer'

class  Module
	def artifact
		class << self
			def inherited(subclass)
			end
			def properties()
				const_get(:HoardProperties).clone
			rescue
				Hash.new 
			end	
		end
	end

	def property(*symbols)
		symbols.each do |symbol|
			property_cfg(symbol, :type => :yaml)
		end
	end

	def property_cfg(symbol, cfg = {})
		puts "property cfg #{symbol}, #{cfg}"
		cfg[:type]  ||= :yaml
		properties = Hash.new

		define_method("#{symbol}=") { |value|
			hook = "#{symbol.to_s}_setter_hook".intern
			old = instance_variable_get("@#{symbol}")
			if self.respond_to? _setter_hook
				self.send(hook, old, value) if old != value
			end
		}
	end
end

class Hoard
	def initialize(controller, name, factory)
		@controller = controller
		@factory = factory
		@dir = File.join($config, name)
		@name = name
	end

	def add(object)
		tmpdir = ".#{object.id}"
		if File.directory?(absolute_path(tmpdir))
			FileUtils::rm_rf(absolute_path(tmpdir))
		end
		mkdir(tmpdir)

		object.get_object.each { |key, value|
			store_property(object, key, tmpdir)
		}
		open("#{tmpdir}/class", 'w') { |o|
			o.print object.class
		}

		rename(tmpdir, object.id)

		self.sync(object.id, 'class')
	end

	def sync(dir, file=nil)
		name = @name
		dir = dir.chomp('/')
		path = "#{name}/#{dir}/#{file}"
		if (file == 'class')
			puts 'Syncer create'
			Syncer.create(path)
		else
			puts 'Syncer add'
			Syncer.add(path)
		end
	end

	def store_property(object, key, dir=nil)
		dir ||= object.id
		object.property_lock.synchronize {

			value = object.get_object[key]	
			path = "#{dir}/#{key}"
			newfile = "#{dir}/#{key}.kkk"
			open(newfile, 'w') { |o|
				if object.yaml?
					YAML.dump(value, o)
				else
					o.write(value)
				end
				o.fsync
			}
			rename(newfile, path)
		}
	end

	def open(path, mode='r', &block)
		File.open(absolute_path(path), mode, &block)
	end

	def mkdir(subdir)
		path = File.join(@dir, subdir)
		puts "mkdir #{path}"
		Dir.mkdir(path)
	end

	def rename(oldpath, newpath)
		puts "rename from #{oldpath} to #{newpath}"
		File.rename(absolute_path(oldpath), absolute_path(newpath))
	end

	def absolute_path(path)
		File.join(@dir, path)
	end
end