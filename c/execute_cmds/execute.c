#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*
 * gcc -o execute.o execute.c
 */

void execute_cmd (char *output)
{
    char *pchBuf = NULL;
    int len = 0;
    char cmd[] = "/bin/ls -l /sys/block > temp.out";
    int r = system (cmd);
    FILE *pFile  = fopen ("temp.out", "r");
    if (pFile == NULL) {
      printf ("failed to read file\n");
      output[len] = '\0';
      return;
    }
    fseek (pFile, 0, SEEK_END);
    len = ftell (pFile);
    rewind (pFile);
    pchBuf = (char*) malloc (sizeof (char) * len + 1);
    if (!pchBuf) {
      printf ("failed to malloc\n");
      output[len] = '\0';
      fclose (pFile);
      return;
    }
    len = fread (pchBuf, sizeof (char), len, pFile);
    pchBuf[len] = '\0';
    strcpy (output, pchBuf);
    output[len] = '\0';
    fclose (pFile);
    free (pchBuf);
}

int main (int argc, char *argv[])
{
  char output[1000];
  execute_cmd (output);
  printf ("result:\n%s\n", output);
}
