#include <stdio.h>
#include <string.h>

int main(int argc, char const *argv[])
{
    char str[6];
    str[0] = 'H';
    str[1] = 'e';
    str[2] = '\0';
    printf("%lu\n", strlen(str));
    return 0;
}