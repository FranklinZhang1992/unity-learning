#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void
get_everrun_passwd (char *passwd)
{
  char salt1[] = "avance";
  char salt2[] = "EVERrun";
  char secret[] = "NNY";
  char *pchBuf = NULL;
  int len = 0;
  FILE *pFile  = fopen ("/shared/creds/root", "r");
  if (pFile == NULL) {
    passwd[0] = '\0';
    return;
  }
  fseek (pFile, 0, SEEK_END);
  len = ftell (pFile);
  rewind (pFile);
  pchBuf = (char*) malloc (sizeof (char) * len + 1);
  if (!pchBuf) {
    passwd[0] = '\0';
    fclose (pFile);
    return;
  }
  len = fread (pchBuf, sizeof (char), len, pFile);
  pchBuf[len] = '\0';
  int i;
  for (i = 0; i < len; i++) {
    pchBuf[i] = pchBuf[i] ^ salt2[i % strlen(salt2)];
    pchBuf[i] = pchBuf[i] ^ secret[i % strlen(secret)];
    pchBuf[i] = pchBuf[i] ^ salt1[i % strlen(salt1)];
  }
  strcpy (passwd, pchBuf);
  passwd[len] = '\0';
  fclose (pFile);
  free (pchBuf);
}

int main(int argc, char const *argv[])
{
    char passwd[100];
    get_everrun_passwd (passwd);
    printf("%s\n", passwd);
    return 0;
}
