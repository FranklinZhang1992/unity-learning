OBJECTS := encryptor_tool_v1.o encryptor_tool_v2.o encryptor_tool_v3.o
LIB := libtomcrypt.a
CC := gcc
CFLAGS = -I./headers

DST ?= dst

INSTALL         = install
INSTALL_PROGRAM = $(INSTALL) --mode=755
INSTALL_DIR     = $(INSTALL) -d --mode=755

.PHONY: clean

default: $(OBJECTS)

$(OBJECTS): %.o: %.c
	$(CC) $(CFLAGS) $< $(LIB) -L. -o $@

install:
	mkdir -p $(DST)
	$(INSTALL_PROGRAM) *.o $(DST)
	$(INSTALL_PROGRAM) run.sh $(DST)
	$(CURDIR)/pkg.sh $(DST)

clean:
	-rm -f *.o
	-rm -rf dst
