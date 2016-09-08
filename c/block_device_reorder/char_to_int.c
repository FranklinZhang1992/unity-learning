#include <stdio.h>
#include <string.h>

/*
 * gcc -o char_to_int.o char_to_int.c
 */
int main (int argc, char const *argv[])
{
  char str[]= "xvda";
  int i;
  printf ("before, str = %s\n", str);
  i = str[strlen (str) - 1];
  i++;
  str[strlen (str) - 1] = i;
  printf ("after, str = %s\n", str);
  return 0;
}
