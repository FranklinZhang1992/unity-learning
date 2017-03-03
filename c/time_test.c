#include <stdio.h>
#include <time.h>

int main(int argc, char const *argv[])
{
    time_t t;
    time(&t);
    printf("ctime is %s\n",ctime(&t));
    return 0;
}
