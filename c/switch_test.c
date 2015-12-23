#include <stdio.h>

#define TYPE_0 0
#define TYPE_1 1
#define TYPE_2 2
#define TYPE_3 3
#define TYPE_4 4

int main(int argc, char const *argv[])
{
  int type;
  printf("Please input type (0, 1, 2, 3, 4)\n");
  scanf("%d", &type);
  switch (type) {
    case TYPE_0:
      printf("type 0\n");
      break;
    case TYPE_1:
    case TYPE_2:
    case TYPE_3:
      printf("type 1 or 2 or 3\n");
      break;
    case TYPE_4:
      printf("type 4\n");
      break;
  }
  return 0;
}
