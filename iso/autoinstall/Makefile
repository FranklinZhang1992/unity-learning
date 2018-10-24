DIRNAME := sources

.PHONY: clean default

default: build

build:
	install -d ISO
	mkisofs -input-charset utf-8 -o ISO/demo.iso $(DIRNAME)

clean:
	-rm -rf ISO
