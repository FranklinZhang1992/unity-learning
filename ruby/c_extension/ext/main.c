#include <stdio.h>
#include "demo.h"

//
// static:
//   gcc -c demo.c
//   ar cr libdemo.a demo.o
//   gcc -o main.o main.c -L. -ldemo
// dynamic:
//   gcc -c demo.c
//   gcc -shared -fPCI -o libdemo.so demo.o
//   gcc -o main.o main.c -L. -ldemo
//   mv libdemo.so /usr/lib
// check lib:
//   ldd main.o
//

int main(int argc, char const *argv[])
{
  double c;
  c = calculate_something(42, 98.6) ;
  printf("calculate_something: %lf\n", c);
  return 0;
}
