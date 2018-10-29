DIRNAME := sources

.PHONY: clean default

default: build

build:
	install -d ISO
	mkisofs -U -input-charset utf-8 -o ISO/demo2.iso $(DIRNAME)

clean:
	-rm -rf ISO
