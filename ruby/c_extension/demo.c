#include <stdio.h>

//
// Generate c lib
// gcc demo.c -fPIC -shared -o libdemo.so
//

double calculate_something(int a, float b)
{
  return a + b;
}
