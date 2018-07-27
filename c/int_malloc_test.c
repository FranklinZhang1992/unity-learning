#include <stdio.h>
#include <stdlib.h>


/*
    gcc -o int_malloc_test.o int_malloc_test.c
*/

void print_int_arr(int *arr, int len)
{
    int i;
    for (i = 0; i < len; i++) {
        printf("%d", arr[i]);
    }
    printf("\n");
}

int main(int argc, char const *argv[])
{
    const int len = 1;
    int *int_arr1;
    int int_arr2[len];
    int i;

    printf("malloc len: %d\n", (sizeof(int) * len));
    printf("array len: %d\n", sizeof(int_arr2));
    int_arr1 = malloc(sizeof(int) * len);

    // Correct example
    for (i = 0; i < len; i++) {
        int_arr1[i] = 1;
    }
    print_int_arr(int_arr1, len);

    // Wrong example, one int takes 4 bytes, so this may affect data in original memory
    for (i = 0; i < len; i++) {
        int_arr2[i] = 2;
    }
    print_int_arr(int_arr2, len);
    return 0;
}
