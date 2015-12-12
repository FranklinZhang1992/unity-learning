# require './hoard/syncer'
require 'monitor'
require 'fileutils'
require 'yaml'

$config = '/home/franklin/temp'
# $config = ''

class Module
	def artifact
		class << self
			def properties() 
				const_get(:HoardProperties).clone rescue Hash.new
			end
		end
	end
end

class Hoard
	def initialize(name)
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
			# Syncer.create(path)
			puts 'Syncer create'
		else
			# Syncer.add(path)
			puts 'Syncer add'
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

class Domain
	# artifact

	attr :id
	attr :name
	attr :object
	def initialize(id, name)
		@id = id
		@name = name
		@object = Hash.new
		object[:id] = @id
		object[:name] = @name
	end
	def get_object
		@object
	end
	def yaml?
		return true
	end
	def property_lock
		if @property_lock.nil?
			@property_lock = Monitor.new
		end
		@property_lock
	end
end

begin
	hoard = Hoard.new('protected_virtual_machine')
	dom = Domain.new('123456', 'test_name')

	# dom.get_object.each {|key, value|
	# 	p dom.get_object[key]
	# }
	hoard.add(dom)
	# Dir.mkdir('/home/franklin/temp/protected_virtual_machine/.123456')
end