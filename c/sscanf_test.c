#include <stdio.h>
#include <string.h>
#include <stdlib.h>

// gcc -o sscanf_test.o sscanf_test.c

int main(int argc, char const *argv[])
{
    char if_name[] = "eth0";
    char if_addr[] = "127.1.1.1";
    char if_vendor[] = "cop";
    char *value;
    asprintf (&value,
                    "<b>%s</b>\n"
                    "<small>"
                    "%s\n"
                    "%s"
                    "</small>\n"
                    "<small><u><span foreground=\"blue\">Identify interface</span></u></small>",
                    if_name,
                    if_addr,
                    if_vendor);

    char *str = strdup (value);
    printf("before (value): %s\n", str);
    sscanf (value, "%*[^>]>%[^<]" , str);
    printf("after (value): %s\n", str);
    free(str);
    return 0;
}
