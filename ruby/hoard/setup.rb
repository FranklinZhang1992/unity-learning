require './service'

$config = '/home/franklin/temp'

begin
	Dir.mkdir("#{$config}/hoard")
	SuperNova.domains.boot
	SuperNova.domains.create()
end