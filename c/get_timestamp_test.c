#include <stdio.h>
#include <sys/time.h>

long getCurrentTime()
{
   struct timeval tv;
   gettimeofday(&tv, NULL);
   return tv.tv_sec * 1000 + tv.tv_usec / 1000;
}

int main()
{
    printf("Timepoint: %ld\n", getCurrentTime());
    return 0;
}
