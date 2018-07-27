#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <stdint.h>
#include <string.h>

/*
    gcc -o raw_code_generator.o raw_code_generator.c
    Usage ./raw_code_generator.o 161a9d1c6b434e998e52e5be7356e438
*/

void print_int_array(const char *title, int *arr, int len)
{
    int i;
    printf("%s\n", title);
    for (i = 0; i < len; i++) {
        printf("%d", arr[i]);
    }
    printf("\n");
}

void print_unchar_array(const char *title, unsigned char *arr, int len)
{
    int i;
    printf("%s\n", title);
    for (i = 0; i < len; i++) {
        printf("%d ", arr[i]);
    }
    printf("\n");
}

uint64_t getCurrentTime()
{
   struct timeval tv;
   gettimeofday(&tv, NULL);
   return tv.tv_sec * 1000 + tv.tv_usec / 1000;
}

void int64_to_bin_array(uint64_t n, int *arr, int nbits)
{
    int i;
    for(i = 0; i < nbits; i++)
    {
        arr[i] = (n >> (nbits - i - 1)) & 1ULL;
    }
    print_int_array("int64_to_bin_array", arr, nbits);
}

void int64_to_bin_digit(uint64_t in, unsigned char *out, int nbytes)
{
    int i;

    for (i = 0; i < nbytes; i++) {
        out[i] = in >> ((nbytes - i - 1) * 8);
    }
}

void get_raw_code(const char *system_uuid, unsigned char *out, int *out_len)
{
    uint64_t systime;
    const int use_first_n = 9;
    const int use_last_n = 4;
    int i, len;
    int buffer_len = use_first_n + use_last_n + 1;
    unsigned char buffer[buffer_len];
    unsigned char *time_bytes;

    if (strlen(system_uuid) != 32) {
        printf("invalid system uuid: %s\n", system_uuid);
        exit(-1);
    }

    // Use first 9 characters of system uuid
    for (i = 0; i < use_first_n; i++) {
        buffer[i] = system_uuid[i];
    }

    systime = getCurrentTime();
    printf("sys time: %Ld\n", systime);
    len = sizeof(systime);
    time_bytes = malloc(sizeof(int) * len);
    int64_to_bin_digit(systime, time_bytes, len);
    print_unchar_array("sys time bytes:", time_bytes, len);

    // Use last 4 bytes of system time (in reverse)
    for (i = 0; i < use_last_n; i++ ) {
        buffer[i + use_first_n] = time_bytes[len - i - 1];
    }
    buffer[buffer_len] = '\0';

    *out_len = strlen(buffer);
    memcpy(out, buffer, *out_len);

    free(time_bytes);
}

int main(int argc, const char *argv[])
{
    char *system_uuid;
    unsigned char out[512];
    int out_len = 0;

    if (argc != 2) {
        printf("invalid argument number: %d\n", argc);
        exit(-1);
    }

    get_raw_code(argv[1], out, &out_len);
    printf("Raw code: %s\n", out);
    printf("Code len: %d\n", out_len);

    return 0;
}
