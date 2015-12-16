#include <stdio.h>
#include "everrun_utils.h"

int main(int argc, char const *argv[])
{
    char *r = get_passwd();
    printf("%s\n", r);
    return 0;
}