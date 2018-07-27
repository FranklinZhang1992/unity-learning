OBJ := encryptor
OBJ2 := main_default
OBJ3 := encryptor_tool_v1
OBJ4 := encryptor_tool_v2
LIB := libtomcrypt.a
CC := gcc
CFLAGS = -I./headers

.PHONY: clean

default: $(OBJ).c
	gcc $(CFLAGS) $(OBJ).c $(LIB) -L. -o $(OBJ).o

demo: $(OBJ2).c
	gcc $(CFLAGS) $(OBJ2).c $(LIB) -L. -o $(OBJ).o

tool: $(OBJ3).c $(OBJ4).c
	gcc $(CFLAGS) $(OBJ3).c $(LIB) -L. -o $(OBJ3).o
	# gcc $(CFLAGS) $(OBJ4).c $(LIB) -L. -o $(OBJ4).o

clean:
	-rm -f *.o
