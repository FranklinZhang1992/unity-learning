LIB_HEADERS := demo.h
LIB_SOURCES := demo.c
LIB_OBJECTS := demo.o
LIBS := demo
TARGETS := demo.so
LIB_DIR := /usr/lib

CC := gcc
C_FLAGS := -c
DY_FLAGS := -shared -fPCI

default: dynamic
static: $(LIB_OBJECTS)
	$(CC) $(C_FLAGS) $(LIB_SOURCES)
	ar cr lib$(LIBS).a $(LIB_OBJECTS)
dynamic: $(LIB_OBJECTS)
	$(CC) $(C_FLAGS) $(LIB_SOURCES)
	$(CC) $(DY_FLAGS) -o lib$(LIBS).so $(LIB_OBJECTS)
$(LIB_OBJECTS): $(LIB_HEADERS)
build:
	$(CC) -o main.o main.c -L. -l$(LIBS)
install:
	cp lib$(LIBS).so $(LIB_DIR)
.PHONY: clean uninstall
clean:
	rm -rf *.so
	rm -rf *.o
	rm -rf *.a
uninstall:
	rm -f $(LIB_DIR)/lib$(LIBS).so
