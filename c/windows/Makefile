GCC_WINDOWS := i686-w64-mingw32-gcc
GCC_LINUX := gcc

# Required package: mingw32-gcc

default:
	$(GCC_WINDOWS) -o app.exe app.c
	$(GCC_LINUX) -o app.o app.c

clean:
	-rm -f app.exe
	-rm -f app.o
