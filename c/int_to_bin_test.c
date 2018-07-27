#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <stdint.h>

uint64_t getCurrentTime()
{
   struct timeval tv;
   gettimeofday(&tv, NULL);
   return tv.tv_sec * 1000 + tv.tv_usec / 1000;
}

void long_to_bin_digit(unsigned long in, unsigned char *out, int *out_len)
{
    int i, len;

    *out_len = sizeof(in);

    for (i = 0; i < *out_len; i++) {
        out[i] = in >> (i * 8);
    }
}

void int64_to_bin_array(uint64_t n, int *arr, int nbits)
{
    int i;
    for(i = 0; i < nbits; i++)
    {
        arr[i] = (n >> (nbits - i - 1)) & 1ULL;
    }
}

int main(int argc, char* argv[])
{
    uint64_t timestamp;
    int i, len;
    int out[64];

    timestamp = getCurrentTime();
    printf("timestamp: %Ld\n", timestamp);

    len = sizeof(timestamp) * 8;
    int64_to_bin_array(timestamp, out, len);
    for (i = 0; i < len; i++) {
        printf("%d", out[i]);
    }
    printf("\n");

    return 0;
}
