require 'rexml/document'

include REXML
e = Element.new('disk')
tmp_source = Element.new('source')
tmp_source.attributes['protocol'] = "http"
tmp_source.attributes['name'] = "http://common.sn.stratus.com/unity/virt-p2v/virt-p2v-livecd-1.28.1-1.49.1.el7.iso"
tmp_host = Element.new('host')
tmp_host.attributes['name'] = "134.111.24.177"
tmp_host.attributes['port'] = "80"
tmp_source << tmp_host
e << tmp_source

puts e

os = Element.new('os')
cmd_line = Element.new('cmdline')
cmd_line.text = "method=http://mirror.sfo12.us.leaseweb.net/fedora/linux/releases/23/Server/x86_64/os/"
os << cmd_line
puts os
