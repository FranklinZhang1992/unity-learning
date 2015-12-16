#include <stdio.h>
#include <string.h>

int match_disk (char *target, char *source)
{
  if ((strcmp (target, source) == 0) || (target[strlen (target) - 1] == source[strlen (source) - 1])) {
    return 1;
  } else {
    return 0;
  }
}

int main(int argc, char const *argv[])
{
  char target[] = "sda";
  char source[] = "vda";
  if (match_disk (target, source)) {
    printf("yes\n");
  } else {
    printf("no\n");
  }
  return 0;
}