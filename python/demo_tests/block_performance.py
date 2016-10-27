from __future__ import print_function
import sys
import libvirt

domName = 'centos72'

conn = libvirt.open('qemu:///system')
if conn == None:
    print('Failed to open connection to qemu:///system', file=sys.stderr)
    exit(1)

dom = conn.lookupByID(53)
if dom == None:
    print('Failed to find the domain '+domName, file=sys.stderr)
    exit(1)

rd_req, rd_bytes, wr_req, wr_bytes, err = \
dom.blockStats('/mnt/everrun/centos72_boot1_8ae9ed2c-56a6-4e80-a114-6f6c5347edf4_node0/centos72_boot1_8ae9ed2c-56a6-4e80-a114-6f6c5347edf4_f22b3fa5-8bb2-4fe6-b9b1-e0895aa619b3')
print('Read requests issued:  '+str(rd_req))
print('Bytes read:            '+str(rd_bytes))
print('Write requests issued: '+str(wr_req))
print('Bytes written:         '+str(wr_bytes))
print('Number of errors:      '+str(err))

conn.close()
exit(0)
