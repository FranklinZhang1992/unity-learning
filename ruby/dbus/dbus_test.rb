# sudo gem install ruby-dbus
require "dbus"
sysbus = DBus.system_bus
upower_service   = sysbus["org.freedesktop.UPower"]
upower_object    = upower_service.object "/org/freedesktop/UPower"
upower_object.introspect
upower_interface = upower_object["org.freedesktop.UPower"]
on_battery       = upower_interface["OnBattery"]
if  on_battery
	puts "The computer IS on battery power."
else
	puts "The computer IS NOT on battery power."
end
