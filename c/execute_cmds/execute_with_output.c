#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/**
 * gcc -o execute_with_output.o execute_with_output.c
 */


void execute_cmd_with_system(char *cmd)
{
    printf("execute cmd with system()\n");
    system(cmd);
}

void execute_cmd_with_popen(char *cmd)
{
    FILE * fp;
    char buffer[80];

    printf("execute cmd with popen()\n");
    if ((fp = popen(cmd, "r") ) != NULL) {
        fgets(buffer, sizeof(buffer), fp);
        printf("%s\n", buffer);
        pclose(fp);
    }
}

int main(int argc, char const *argv[])
{
    char *cmd = NULL;

    cmd = strdup("echo Hello!");
    execute_cmd_with_system(cmd);
    execute_cmd_with_popen(cmd);
    free(cmd);
    return 0;
}
