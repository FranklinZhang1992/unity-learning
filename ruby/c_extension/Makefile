SOURCES := demo.c
TARGETS := demo.so
GCC := gcc
GCC_FLAGS := -fPIC -shared

default: build install
build: $(TARGETS)
$(TARGETS): %.so: %.c
	$(GCC) $< $(GCC_FLAGS) -o lib$@
install:
	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:.
.PHONY: clean
clean:
	rm -rf *.so
	rm -rf *.o
