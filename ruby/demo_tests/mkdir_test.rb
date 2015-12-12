require 'fileutils'

config = '/home/franklin/temp/hoard'
name = "pvm"
dir = File.join(config, name)
trash = File.join(dir, '.trash')
FileUtils::mkdir_p trash