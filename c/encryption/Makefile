OBJ := encryptor
OBJ2 := main_default
LIB := libtomcrypt.a
CC := gcc
CFLAGS = -I./headers

.PHONY: clean

default: $(OBJ).c
	gcc $(CFLAGS) $(OBJ).c $(LIB) -L. -o $(OBJ).o

demo: $(OBJ2).c
	gcc $(CFLAGS) $(OBJ2).c $(LIB) -L. -o $(OBJ).o

clean:
	-rm -f $(OBJ).o
	-rm -f $(OBJ2).o
