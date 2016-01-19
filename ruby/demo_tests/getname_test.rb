require 'resolv'

begin puts Resolv.getaddress("http://ruby-doc.org/stdlib-1.9.3/libdoc/resolv/rdoc/Resolv.html") rescue puts "unknown" end

begin puts Resolv.getname("115.239.211.112") rescue puts "unknown" end

begin puts Resolv.getname("115.239.210.27") rescue puts "unknown" end
