TOOL_V1 := encryptor_tool_v1
TOOL_V2 := encryptor_tool_v2
LIB := libtomcrypt.a
CC := gcc
CFLAGS = -I./headers

.PHONY: clean

default: $(TOOL_V1).c $(TOOL_V2).c
	gcc $(CFLAGS) $(TOOL_V1).c $(LIB) -L. -o $(TOOL_V1).o
	gcc $(CFLAGS) $(TOOL_V2).c $(LIB) -L. -o $(TOOL_V2).o

clean:
	-rm -f *.o
