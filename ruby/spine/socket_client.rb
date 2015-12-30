require 'socket'

address = '192.168.234.62'
# address = 'localhost'
port = 8999

$UUID = '1eca8d99-6931-4ff5-a06d-369f297e8846'
serial = Time.now.to_f
name = 'DomainService'
symbol = 'rename'
args = 'mike'


message = {
    :node => $UUID,
    :ident => serial,
    :service => name,
    :method => symbol,
    :args => args
}

s = UDPSocket.new(Socket::AF_INET6)
sent_size = s.send(Marshal.dump(message), 0, address, 8999)

# while line = s.gets
#     puts line.chop
# end
# s.close
