#include <stdio.h>
#include <string.h>

char* get_passwd ()
{
    char salt1[] = "avance";
    char salt2[] = "EVERrun";
    char secret[] = "NNY";

    FILE *pFile  = fopen("/shared/creds/root", "r");
    if (pFile == NULL)
    {
        printf("error\n");
        return NULL;
    }
    fseek(pFile,0,SEEK_END);
    int len=ftell(pFile) - 1;
    char pw[len + 1];
    rewind(pFile);
    fread(pw,1,len,pFile);
    pw[len]='\0';
    fclose(pFile);

    int i;
    for (i = 0; i < len; i++)
    {
        pw[i] = pw[i] ^ salt2[i % strlen(salt2)];
        pw[i] = pw[i] ^ secret[i % strlen(secret)];
        pw[i] = pw[i] ^ salt1[i % strlen(salt1)];
    }

    const len2 = strlen(pw);
    static char pass[100];
    strcpy(pass, pw);
    return pass;
}

int main(int argc, char const *argv[])
{

    char *r = get_passwd();
    printf("%s\n", r);
    return 0;
}