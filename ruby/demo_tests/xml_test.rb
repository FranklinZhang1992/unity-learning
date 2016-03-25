require 'rexml/document'

include REXML
def xml_str
  "<?xml version='1.0'?><domain id=\"90fffbc9-c652-41c4-a9d0-f9d948055687\"><virtualization>hvm</virtualization><name>denmark-test</name><vcpus>1</vcpus><memory>1024</memory><availability>FT</availability><volumes><volume><region ref=\"109ee282-5096-4942-9281-67dffc68b0f2\" /><boot>true</boot></volume><volume><region ref=\"5e012dd9-c661-4c69-aa61-ad1db40278d5\" /></volume></volumes><interfaces><interface><network ref=\"2001c1a5-a367-40d5-8b4a-3d259e4c5585\"/></interface></interfaces><hardware_uuid>7c4b65b9-d178-4cbc-b852-9a1613b27b53</hardware_uuid><hardware_sn>e1ff18b7-6e5a-4239-a62c-7a6edce373bf</hardware_sn></domain>"
end

def remove_xml_node
  iso_id = "5e012dd9-c661-4c69-aa61-ad1db40278d5"
  xml = Document.new(xml_str).root
  volumes_xml = xml.elements['volumes']
  empty = Element.new
  find_iso_id = false
  puts "before: #{volumes_xml}"
  (volumes_xml||empty).elements.each do |volxml|
    id = volxml.elements['region '].attributes['ref']
    if id == iso_id
      puts "find iso id #{id}"
      find_iso_id = true
      volumes_xml.delete_element(volxml)
    end
  end
  puts "after: #{volumes_xml}"
end

def get_value
  empty = Element.new
  xml = Document.new(xml_str).root
  value1 = (xml.elements['name']||empty).text
  value2 = (xml.elements['test']||empty).text
  puts "value1 = #{value1}, value2 = #{value2}"
end

# remove_xml_node
# get_value

str = '<td class="reserved">0% DUT 10g Rel=3.1.1 Vms=4 dr drbd2 model_t310 processor_nehalem rack_7c raid sc_perc_6i simplexboot sn vendor_dell vlanFault Reserved: untriage at 23-Feb 15:10; FAILED IMAGE of DUT (check physical nodes, possibly known Power or BMC Issue) (AUTO), overnight</td>'
doc = Document.new(str)
p doc.root
