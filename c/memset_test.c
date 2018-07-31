#include <stdio.h>
#include <string.h>

/*
    gcc -o memset_test.o memset_test.c
*/

int main(int argc, char const *argv[])
{
    int i;
    int array[10];
    memset(array, -1, sizeof(array));

    for (i = 0; i < 10; i++) {
        printf("%d\n", array[i]);
    }
    return 0;
}
