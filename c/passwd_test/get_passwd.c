#include <stdio.h>
#include <string.h>

void
get_everrun_passwd (char *passwd)
{
    char salt1[] = "avance";
    char salt2[] = "EVERrun";
    char secret[] = "NNY";

    FILE *pFile  = fopen("/shared/creds/root", "r");
    if (pFile == NULL)
    {
        passwd[0] = '\0';
        return;
    }
    fseek(pFile,0,SEEK_END);
    int len = ftell(pFile) - 1;
    char pw[len + 1];
    rewind(pFile);
    pw[len] = '\0';
    fclose(pFile);
    printf("%s\n", pw);
    int i;
    for (i = 0; i < len; i++)
    {
        pw[i] = pw[i] ^ salt2[i % strlen(salt2)];
        pw[i] = pw[i] ^ secret[i % strlen(secret)];
        pw[i] = pw[i] ^ salt1[i % strlen(salt1)];
    }

    strcpy(passwd, pw);
    passwd[len] = '\0';
}

int main(int argc, char const *argv[])
{
    char passwd[100];
    get_everrun_passwd (passwd);
    printf("%s\n", passwd);
    return 0;
}
