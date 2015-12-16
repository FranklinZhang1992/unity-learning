#include <string.h>
#include <ctype.h>
#include <stdio.h>
// #include <stdlib.h>

void trim(char* origin, char *result )
{
    int i = 0;
    int len = strlen(origin);
    int j = len - 1;
    int pos = 0;

    while (origin[i] != '\0' && isspace(origin[i]))
    {
        ++i;
    }
    while (origin[j] != '\0' && isspace(origin[j]))
    {
        --j;
    }
    while (i <= j)
    {
        result[pos++] = origin[i++];
    }
    printf("[franklin][c]###%s###\n", result);
}

int main()
{
    char* str = "Hello world"; // 这里面混合了制表符 空格和换行
    char res[strlen(str)];
    printf("###%s###\n", str);
    // char* res1;
    trim(str, res);
    printf("###%s###\n", res);
    trim(str, res);
    printf("###%s###\n", res);

    // free(res1);
    // res1 = NULL;
    return 0;
}