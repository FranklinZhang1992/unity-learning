require 'openssl'

begin
    key_file = "/home/franklin/download/certs/customer/server.key"
    cert_file = "/home/franklin/download/certs/customer/server.crt"

    key_file2 = "/home/franklin/download/certs/everrun/server.key"
    cert_file2 = "/home/franklin/download/certs/everrun/server.crt"

    key_file3 = "/home/franklin/workspace/mine/unity-learning/ruby/web_server/cert/server.key"
    cert_file3 = "/home/franklin/workspace/mine/unity-learning/ruby/web_server/cert/server.crt"

    key_file4 = "/home/franklin/download/certs/validation/root.key"
    cert_file4 = "/home/franklin/download/certs/validation/root.crt"

    key_file5 = "/home/franklin/download/certs/validation/server.key"
    cert_file5 = "/home/franklin/download/certs/validation/server.crt"

    pkey = OpenSSL::PKey::RSA.new File.read key_file5
    cert = OpenSSL::X509::Certificate.new File.read cert_file5


    cmd1 = "openssl x509 -noout -modulus -in #{cert_file5} | openssl md5"
    cmd2 = "openssl rsa -noout -modulus -in #{key_file5} | openssl md5"
    cmd3 = "openssl -verify #{cert_file2}"

    result1 = %x{#{cmd1}}
    result2 = %x{#{cmd2}}
    # result3 = %x{#{cmd3}}
    puts "result1 => #{result1}"
    puts "result2 => #{result2}"
    # puts "result3 => #{result3}"

    # puts "public?: #{pkey.public?}"
    # puts "private?: #{pkey.private?}"
    if cert.verify pkey
        puts "certificate verify succeed"
    else
        puts "certificate verify failed"
    end
rescue Exception => e
    raise
end
