INSTALL=install
CURRENT_DIR=$(shell pwd)
SOURCE=$(CURRENT_DIR)/src/server.rb
SERVICE_FILE=$(CURRENT_DIR)/usr/lib/systemd/system/simple_server.service

.PHONY: test

default: build

build: test

install:
	$(INSTALL) --mode=755 $(SOURCE) /usr/bin/simple_server
	$(INSTALL) --mode=755  $(SERVICE_FILE) /usr/lib/systemd/system/
	systemctl daemon-reload

uninstall:
	-rm -f /usr/bin/simple_server
	-rm -f /usr/lib/systemd/system/simple_server.service

test:
