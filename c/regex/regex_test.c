#include <regex.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

char *sub_string(char *str, int start, int end)
{
static char * st = NULL;
int i = start, j = 0;
st ? free(st) : 0;
st = (char *)malloc(sizeof(char) * (end - start + 1));
while(i < end){
st[j++] = str[i++];
}
st[j] = '\0';
return st;
}

int main()
{
regmatch_t pm[4];
regex_t preg;
// char *pattern = "^[-][i][ ][l][i][b][v][i][r][t][x][m][l]*";
char *pattern = "^[-][i][ ]([a-z]*[a-z])*";
char *file = "-i libvirtxml /tmp/config.xml", *st;
char *file1 = "-i ova /tmp/test.ova";

if (regcomp(&preg, pattern, REG_EXTENDED |REG_NEWLINE) != 0){ //编译正则表达式
fprintf(stderr, "Cannot regex compile!");
return -1;
}
st = file;
// st = file1;

if (regexec(&preg, st, 4, pm, REG_NOTEOL) == 0){ //开始匹配
    printf("###%s###\n",sub_string(st, pm[0].rm_so, pm[0].rm_eo));

}
regfree(&preg);
return 0;
}