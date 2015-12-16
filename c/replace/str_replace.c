#include <stdio.h>
#include <string.h>

void filter_invalid_character (char *in, char *out)
{

}


void strrpl (char *in, char *out, const char *src, const char *dst)
{
    if (in == NULL || out == NULL || src == NULL || dst == NULL)
    {
        return;
    }
    if (strcmp (in, "") == 0 || strcmp (src, "") == 0)
    {
        strcpy (out, in);
    }
    char *pi = in;
    char *po = out;

    int inLen = strlen (in);
    int srcLen = strlen (src);
}


void strrpl(char* pDstOut, char* pSrcIn, const char* pSrcRpl, const char* pDstRpl)
{
char* pi = pSrcIn;
char* po = pDstOut;

int nSrcRplLen = strlen(pSrcRpl);
int nDstRplLen = strlen(pDstRpl);

char *p = NULL;
int nLen = 0;

do
{
// 找到下一个替换点
p = strstr(pi, pSrcRpl);

if(p != NULL)
{
// 拷贝上一个替换点和下一个替换点中间的字符串
nLen = p - pi;
memcpy(po, pi, nLen);

// 拷贝需要替换的字符串
memcpy(po + nLen, pDstRpl, nDstRplLen);
}
else
{
strcpy(po, pi);

// 如果没有需要拷贝的字符串,说明循环应该结束
break;
}

pi = p + nSrcRplLen;
po = po + nLen + nDstRplLen;

} while (p != NULL);
}

int main(int argc, char const *argv[])
{
    // char in[] = "9a.1 6A}i¤a80)}vhn]MVe{y;";
    char in[] = "abcd";
    char out[100];
    // char src[] = "[\\x00-\\x08\\x0b-\\x0c\\x0e-\\x1f]";
    char src[] = "d";
    char dst[] = "";
    int outlen = 100;
    printf("%s\n", in);
    strrpl (out, in, src, dst);
    printf("%s\n", out);

    return 0;
}