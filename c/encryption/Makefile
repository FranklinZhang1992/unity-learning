OBJ := encryptor
LIB := libtomcrypt.a
CC := gcc
CFLAGS = -I./headers

.PHONY: clean

default: $(OBJ).c
	gcc $(CFLAGS) $(OBJ).c $(LIB) -L. -o $(OBJ).o

clean:
	-rm -f $(OBJ).o
