#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int write_file(const char *filename, const char *content)
{
    FILE *fp;

    fp = fopen (filename, "a");
    fprintf(fp, "%s\r\n", content);

    fclose(fp);

    return 0;
}

void get_sys_time(char *buffer, int len)
{
    time_t timer;
    struct tm * timeinfo;

    time(&timer);
    timeinfo = localtime(&timer);
    strftime(buffer, len, "%Y-%m-%d %H:%M:%S", timeinfo);
}

int main(int argc, char const *argv[])
{
    int i, count;
    char *msg = "Hello World!";
    char *filename = "C:\\output\\app.out";
    char content[100];
    char buffer[26];

    count = 3;

    for (i = 0; i < count; i++) {
        get_sys_time(buffer, 26);
        sprintf(content, "[%s] %s", buffer, msg);
        write_file(filename, content);
        printf("[%d] Write file, content: %s\n", i, content);
        sleep(1);
    }

    printf("Complete\r\n");
    return 0;
}
