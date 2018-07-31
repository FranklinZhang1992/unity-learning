#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*
    gcc -o bit_to_char_test.o bit_to_char_test.c
*/

int bits_to_char(int *in, int in_len, unsigned char *out)
{
    int i;
    unsigned int t;
    if (in_len % 8 != 0) {
        printf("invalid bit array length %d\n", in_len);
        return -1;
    }
    t = 0;
    for (i = 0; i < in_len; i++) {
        t |= (in[i] << (8 - i -1));
    }
    *out = t;
    return 0;
}

int char_to_bits(unsigned char in, unsigned int *out, int *out_len)
{
    int i, j;
    j = 0;
    for (i = 0; i < 8; i++) {
        out[j++] = (in >> (8 - i - 1)) & 1ULL;
    }
    *out_len = j;
    return 0;
}

int int_to_bits(unsigned int in, unsigned int *out, int *out_len)
{
    int i, j;
    j = 0;
    for (i = 0; i < 8; i++) {
        out[j++] = (in >> (8 - i - 1)) & 1ULL;
    }
    *out_len = j;
    return 0;
}

int main(int argc, char *argv[])
{
    int err, bits[8], len, i;
    char out;
    len = strlen(argv[1]);
    if (len != 8) {
        printf("Invalid argument length: %d\n", len);
        exit(-1);
    }
    for (i = 0; i < len; i++) {
        if (argv[1][i] == '0') {
            bits[i] = 0;
        } else if (argv[1][i] == '1') {
            bits[i] = 1;
        } else {
            printf("Input contains invalid character: %s\n", argv[1]);
            exit(-1);
        }
    }
    printf("Converting: ");
    for (i = 0; i < len; i++) {
        printf("%d", bits[i]);
    }
    printf("\n");
    if ((err = bits_to_char(bits, len, &out)) != 0) {
        printf("error converting bits to char\n");
        exit(-1);
    }
    printf("Result: %d\n", out);

    if ((err = char_to_bits(out, bits, &len)) != 0) {
        printf("error converting char to bits\n");
        exit(-1);
    }
    printf("Revert:\n");
    for (i = 0; i < len; i++) {
        printf("%d", bits[i]);
    }
    printf("\n");
    return 0;
}
