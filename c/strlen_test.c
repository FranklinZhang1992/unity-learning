#include <stdio.h>
#include <string.h>
#include <stdlib.h>
int main(int argc, char const *argv[])
{
  char *array = NULL;
  int len;
  array = malloc (10);
  memset (array, 0, 10);
  len = strlen (array);
  printf("len = %d\n", len);
  return 0;
}