require 'rexml/document'

include REXML
begin
  body = "<?xml version='1.0'?><domain-rename><new-name>f-test</new-name></domain-rename>"
  doc = REXML::Document.new(body)
  puts "doc is #{doc}"
  root = doc.root
  puts "root is #{root}"
  puts "root.name is #{root.name}"
  if root.name == 'domain-rename'
    puts "yes"
    new_name = begin root.elements['new-name'].text rescue '' end
    puts new_name
  end
rescue Exception => e
  puts "exception occur => #{e}"
end
