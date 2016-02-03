#include <stdio.h>
#include <stdint.h>

int main(int argc, char const *argv[])
{
  int16_t num;
  int16_t num2;
  num = 32767;
  num2 = -32768;
  printf("%d\n", num);
  printf("%d\n", num2);
  return 0;
}
