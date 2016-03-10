#include <stdio.h>

// gcc for_test.c -o for_test.out -std=c99
int main(int argc, char const *argv[])
{
  for (int i = 0; i < 5; i++); printf("Hello\n");
  for (int i = 0; i < 5; i++) {
    printf("World\n");
  }
  return 0;
}
