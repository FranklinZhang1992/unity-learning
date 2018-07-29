TOOL_V1 := encryptor_tool_v1
TOOL_V2 := encryptor_tool_v2
LIB := libtomcrypt.a
CC := gcc
CFLAGS = -I./headers

DST ?= dst

INSTALL         = install
INSTALL_PROGRAM = $(INSTALL) --mode=755
INSTALL_DATA    = $(INSTALL) --mode=644
INSTALL_DIR     = $(INSTALL) -d --mode=755

.PHONY: clean

default: $(TOOL_V1).c $(TOOL_V2).c
	gcc $(CFLAGS) $(TOOL_V1).c $(LIB) -L. -o $(TOOL_V1).o
	gcc $(CFLAGS) $(TOOL_V2).c $(LIB) -L. -o $(TOOL_V2).o

install:
	mkdir -p $(DST)
	$(INSTALL_PROGRAM) *.o $(DST)
	$(INSTALL_PROGRAM) run.sh $(DST)

clean:
	-rm -f *.o
	-rm -rf dst
