INSTALL=install
CURRENT_DIR=$(shell pwd)
SOURCE=$(CURRENT_DIR)/src/server.rb

.PHONY: test

default: build

build: test

install:
	$(INSTALL) --mode=755 $(SOURCE) /usr/bin/simple_server
	$(INSTALL) --mode=755 etc/rc.d/init.d/* /etc/rc.d/init.d/

uninstall:
	-rm -f /usr/bin/simple_server
	-rm -f /etc/rc.d/init.d/simple_server

test:
