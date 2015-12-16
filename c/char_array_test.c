#include <stdio.h>
#include <crypt.h>
#include <string.h>

char*
get_chomp_string (char *s)
{
  int i = 0;
  int j = strlen ( s ) - 1;
  int k = 0;
  printf("i=%i\n", i);
  printf("j=%i\n", j);
  while ( s[i] == ' ' && i <= j )
  {
    i++;
  }
printf("i=%i\n", i);
  while ( s[j] == ' ' && j >= 0 )
  {
    j--;
  }
  printf("j=%i\n", j);
  printf("first is %s\n", &s[i]);
  printf("last is %s\n", &s[j]);

printf("result is###%s###\n", &s[0]);
  while ( i <= j )
  {
     printf("i=%i\n", i);
    printf("j=%i\n", j);
    s[k++] = s[i++];
  }

  s[k] = '\0';
  printf("result is###%s###\n", &s[0]);
  return s;
}

int main(int argc, char const *argv[])
{
    char *origin = "   This is origin   ";
    // char *modified;
    get_chomp_string(origin);
    // printf("#####%s#####\n", modified);
    return 0;
}



// /*去除字符串右边空格*/
// void VS_StrRTrim(char *pStr)
// {
//     char *pTmp = pStr+strlen(pStr)-1;

//     while (*pTmp == ' ')
//     {
//         *pTmp = '/0';
//         pTmp--;
//     }
// }

// /*去除字符串左边空格*/
// void VS_StrLTrim(char *pStr)
// {
//     char *pTmp = pStr;

//     while (*pTmp == ' ')
//     {
//         pTmp++;
//     }
//     while(*pTmp != '/0')
//     {
//         *pStr = *pTmp;
//         pStr++;
//         pTmp++;
//     }
//     *pStr = '/0';
// }