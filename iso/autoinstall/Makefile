DIRNAME := sources

.PHONY: clean default

default: build

build:
	install -d ISO
	mkisofs -U -V "Guest Monitoring Agent" -input-charset utf-8 -o ISO/demo.iso $(DIRNAME)

clean:
	-rm -rf ISO
