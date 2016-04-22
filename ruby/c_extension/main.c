#include <stdio.h>
#include "demo.h"

//
// ref: http://www.linux521.com/2009/system/201204/16127.html
// gcc main.c -L. -ldemo -o main.o
// export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:.
// ldd main
//

int main(int argc, char const *argv[])
{
  double c;
  c = calculate_something(42, 98.6) ;
  printf("calculate_something: %lf\n", c);
  return 0;
}
