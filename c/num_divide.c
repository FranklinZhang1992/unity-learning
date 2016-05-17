#include <stdio.h>
#include <math.h>

// 
// gcc -o num_divide.o num_divide.c
// 

int main (int argc, char const *argv[])
{
  float number;
  double f, i;
  printf ("input the number\n");
  scanf ("%f", &number);
  f = modf (number, &i);
  printf ("%f = %f + %f\n", number, i, f);
  return 0;
}
