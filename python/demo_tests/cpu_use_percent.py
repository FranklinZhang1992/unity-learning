from __future__ import print_function
import sys
import libvirt

domName = 'win10_pro_x86'

conn = libvirt.open('qemu:///system')
if conn == None:
    print('Failed to open connection to qemu:///system', file=sys.stderr)
    exit(1)

dom = conn.lookupByID(64)
if dom == None:
    print('Failed to find the domain '+domName, file=sys.stderr)
    exit(1)

cpu_stats = dom.getCPUStats(False)
for (i, cpu) in enumerate(cpu_stats):
   print('CPU '+str(i)+' Time: '+str(cpu['cpu_time'] / 1000000000.))

conn.close()
exit(0)
