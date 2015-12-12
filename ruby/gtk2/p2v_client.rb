require 'gtk2'
require 'fileutils'

TRY_AGAIN   = 0
DEBUG       = 1
POWER_OFF   = 2

LOG = '/tmp/virt-p2v.log'

# Touching this file lets the X wrapper know we ran
FileUtils.touch('/tmp/virt-p2v-launcher')

def choose
    option = nil

    window = Gtk::Window.new
    window.window_position = Gtk::Window::POS_CENTER_ALWAYS
    window.decorated = false
    window.resizable = false
    window.set_default_size(200, 200)

    vbox = Gtk::VBox.new(false, 10)
    hbox = Gtk::HBox.new(true, 10)

    buttons = [
        [ 'Try Again', TRY_AGAIN ],
        [ 'Debug', DEBUG ],
        [ 'Power off', POWER_OFF ]
    ]

    buttons.each { |button|
        label = button[0]
        clicked = button[1]

        w = Gtk::Button.new(label)
        w.signal_connect('clicked') {
            option = clicked
            window.destroy
            Gtk.main_quit
        }
        hbox.pack_start(w)
    }

    l = Gtk::Label.new(<<MSG)
virt-p2v has shutdown unexpectedly. You may:

* Try running it again
* Debug virt-p2v
* Power the machine off
MSG

    vbox.border_width = 10
    vbox.add(l)
    vbox.add(hbox)
    window.add(vbox)

    window.show_all
    Gtk.main

    return option
end

loop {
    # system('/bin/sh', '-c', "exec /usr/bin/virt-p2v > #{LOG} 2>&1")
    # status = $?
    # break if status.success?

    o = choose
    break if o == POWER_OFF
    next if o == TRY_AGAIN
    # system('/usr/bin/openvt', '-sw', '--', '/bin/sh', '-c', <<DEBUG)
# clear
# echo Output was written to #{LOG}
# echo Any core files will have been written to /tmp
# echo Exit this shell to run virt-p2v again.
# bash -l
# clear
# DEBUG
}

