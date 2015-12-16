#include <stdio.h>
#include <string.h>

int main(int argc, char const *argv[])
{
    int len = 7;
    char salt2[] = "EVERrun";
    printf("%lu\n", strlen(salt2));
    int i;
    for (i = 0; i < len * 2; i++)
    {
        char temp = salt2[i % strlen(salt2)];
        printf("%c\n", temp);
    }
    return 0;
}