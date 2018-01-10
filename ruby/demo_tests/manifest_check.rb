MANIFEST_SHA_PATTERN = "(SHA1|SHA256)\\((.*)\\)= ([0-9a-fA-F]+)?"

pattern = Regexp.new(MANIFEST_SHA_PATTERN)

verify_str = "SHA1(win10_pro_x64-disk1.vmdk)= f515a69a0a67242648c2c37e0c07336e7f282fa8"
matched = pattern.match(verify_str)
p matched
