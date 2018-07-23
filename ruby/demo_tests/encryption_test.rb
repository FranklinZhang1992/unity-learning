require "base64"

def encrypt(plaintext)
    passwd = "161a9d1c6b434e998e52e5be7356e438"
    encrypted = %x{echo '#{plaintext}' | openssl aes-128-ctr -a -salt -k #{passwd}}.strip
    puts "After encrypt: #{encrypted}, len = #{encrypted.length}"

    decrypted = %x{echo '#{encrypted}' | openssl aes-128-ctr -d -a -salt -k #{passwd}}.strip
    puts "After decrypt: #{decrypted}, len = #{decrypted.length}"
    puts "###########################################################"
end

encrypt("6afa31dba6598")
encrypt("6afa31dba6599")
