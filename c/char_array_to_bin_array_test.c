#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

/*
    gcc -o char_array_to_bin_array_test.o char_array_to_bin_array_test.c

    Usage: ./char_array_to_bin_array_test.o ab
*/

void print_int_array(const char *title, int *arr, int len)
{
    int i;
    printf("%s: ", title);
    for (i = 0; i < len; i++) {
        printf("%d", arr[i]);
    }
    printf("\n");
}

int char_arr_to_bin_arr(unsigned char *in, int in_len, int *out)
{
    int i, j, k, nbits;

    j = 0;
    for (i = 0; i < in_len; i++) {
        nbits = sizeof(in[i]) * 8; // 1byte = 8 bits
        for (k = 0; k < nbits; k++) {
            out[j] = (in[i] >> (nbits - (k % nbits) - 1)) & 1ULL;
            j++;
        }
    }
    return j;
}

int bin_arr_to_char_arr(int *in, int in_len, unsigned char *out)
{
    int i, j;
    if (in_len % 8 != 0) {
        printf("invalid bin array length %d\n", in_len);
        return -1;
    }

    memset(out, 0, sizeof(out) - 1);
    for (i = j = 0; i < in_len; i++) { // 1byte = 8 bits
        out[j] |= (in[i] << (8 - i % 8 -1));
        if ((i + 1) % 8 == 0)
            j++;
    }
    out[j] = '\0';
    return j;
}

int main(int argc, char *argv[])
{
    unsigned char *in;
    unsigned char out2[1024];
    int out[1024];
    int i, len;

    if (argc < 2) {
        printf("num required\n");
        exit(-1);
    }
    in = argv[1];
    printf("Input: %s\n", in);

    len = char_arr_to_bin_arr(in, strlen(in), out);
    print_int_array("Output", out, len);

    len = bin_arr_to_char_arr(out, len, out2);
    printf("Output: %s\n", out2);

    return 0;
}
