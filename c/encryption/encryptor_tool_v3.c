#include <tomcrypt.h>
#include <stdlib.h>
#include <sys/time.h>
#include <stdint.h>
#include <string.h>

/*
 * Compile:
 *     make
 *
 * Usage: ./encryptor_tool_v3.o -e 161a9d1c6b434e998e52e5be7356e438 -v
 *         IV: 1111101010011010011110000101001101100010101000000111110011000100
 *   Raw Code: 64V32R9SCK4ZSNQE
 * Final Code: YFCF1-QS5BS-QJH78-TB1ST
 *        ./encryptor_tool_v3.o -d 161a9d1c6b434e998e52e5be7356e438 9A1WX1-K9ZADN-M41WJD-8GRP60 -v
 *   Raw Code: 64V32R9SCK4ZSNQE
 *
 */

int verbose = 0;
const unsigned char *iv_suf_template = "SAMPLEIVSUFFIX";
const char *cipher = "blowfish";
int cipher_idx, hash_idx, ks, ivsize;
const char *encode_array = "0123456789ABCDEFGHJKMNPQRSTUVWXY";

int usage(char *name)
{
   int x;

   printf("Usage encrypt: %s -e uuid\n", name);
   printf("Usage decrypt: %s -d uuid ciphertext(Base32)\n", name);
   exit(1);
}

void print_int_array(const char *title, unsigned int *arr, int len)
{
    int i;
    printf("%s: ", title);
    for (i = 0; i < len; i++) {
        printf("%d", arr[i]);
    }
    printf("\n");
}

void print_unchar_array(const char *title, unsigned char *arr, int len)
{
    int i;
    printf("%s:\n", title);
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

void int64_to_bin_digit(uint64_t in, unsigned char *out, int nbytes)
{
    int i;

    for (i = 0; i < nbytes; i++) {
        out[i] = in >> ((nbytes - i - 1) * 8);
    }
}

int char_arr_to_bin_arr(unsigned char *in, int in_len, unsigned int *out)
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

int bin_arr_to_char_arr(int *in, int in_len, unsigned char *out)
{
    int i, j, k, ret;
    int tmp[8];
    unsigned char c;
    if (in_len % 8 != 0) {
        printf("invalid bin array length: %d\n", in_len);
        return -1;
    }

    memset(tmp, 0, sizeof(tmp));
    for (i = j = k = 0; i < in_len; i++) { // 1byte = 8 bits
        tmp[j++] = in[i];
        if (j == 8) {
            j = 0;
            if ((ret = bits_to_char(tmp, 8, &c)) != 0) {
                printf("failed converting bits to char\n");
                return -1;
            }
            out[k++] = c;
        }
    }
    out[k] = '\0';
    return k;
}

void substring(char *in, unsigned char *out, int in_start_Index, int in_end_index, int out_start_index)
{
   int total_len;
   int i, j;

   total_len = strlen(in);
   if (in_end_index > total_len) {
      printf("invalid end index: %d\n", in_end_index);
      return;
   }
   if (in_start_Index < 0 ) {
      printf("invalid start index: %d\n", in_start_Index);
      return;
   }
   if (out_start_index < 0 ) {
      printf("invalid start index: %d\n", out_start_index);
      return;
   }

   j = out_start_index;
   for (i = in_start_Index; i < in_end_index; i++) {
      out[j++] = in[i];
   }
   out[j] = '\0';
}

void print_raw_code(unsigned char *raw_code)
{
   unsigned char encoded_code[512];
   unsigned long raw_code_len, encoded_code_len;
   int err, i, len, uuid_bytes, time_bytes;

   encoded_code_len = sizeof(encoded_code);
   raw_code_len = strlen((char *) raw_code);
   if ((err = base32_encode(raw_code, raw_code_len, encoded_code, &encoded_code_len, BASE32_CROCKFORD)) != CRYPT_OK) {
      printf("base32 encode error: %s\n", error_to_string(err));
      exit(-1);
   }
   printf("[Raw code] %s\n", encoded_code);

   uuid_bytes = 6;
   time_bytes = 4;
   len = strlen((char *) raw_code);
   if (len != (uuid_bytes + time_bytes)) {
      printf("Invalid raw code length: %d\n", len);
      exit(-1);
   }
   printf("First %d bytes of UUID: ", uuid_bytes);
   for (i = 0; i < uuid_bytes; i++) {
      printf("%c", raw_code[i]);
   }
   printf("\nLast %d bytes of time (in decimal): ", time_bytes);
   for (i = uuid_bytes; i < uuid_bytes + time_bytes; i++) {
      printf("%d ", raw_code[i]);
   }
   printf("\n");
}

int get_raw_code(char *uuid, uint64_t systime, unsigned char *out)
{
    const int use_first_n = 6;
    const int use_last_n = 4;
    int i, len;
    int buffer_len = use_first_n + use_last_n + 1;
    unsigned char buffer[buffer_len];
    unsigned char *time_bytes;

    if (strlen(uuid) != 32) {
        printf("invalid UUID: %s\n", uuid);
        exit(-1);
    }

    // Use first 9 characters of uuid
    for (i = 0; i < use_first_n; i++) {
        buffer[i] = uuid[i];
    }

    len = sizeof(systime);
    time_bytes = malloc(sizeof(unsigned char) * len);
    int64_to_bin_digit(systime, time_bytes, len);
    if (verbose)
      print_unchar_array("System time bytes:", time_bytes, len);

    // Use last 4 bytes of system time (in reverse)
    for (i = 0; i < use_last_n; i++ ) {
        buffer[i + use_first_n] = time_bytes[len - i - 1];
    }
    buffer[i + use_first_n] = '\0';

    memcpy(out, buffer, strlen(buffer));

    free(time_bytes);
    return strlen(out);
}

int entangle_iv(unsigned int *iv_pre_bits,
                         int iv_pre_bits_len,
                unsigned int *iv_suf_bits,
                         int iv_suf_bits_len,
                unsigned char *iv_out)
{
   unsigned int buffer_bits[1024];
   int i, j, p0, p1, p2;
   int ret;

   if (iv_pre_bits_len != 20) {
      printf("Invalid IV prefix bits length: %d\n", iv_pre_bits_len);
      exit(-1);
   }
   if (iv_suf_bits_len != 44) {
      printf("Invalid IV suffix bits length: %d\n", iv_suf_bits_len);
      exit(-1);
   }

   if (verbose) {
      printf("IV prefix len: %d, IV suffix len: %d\n", iv_pre_bits_len, iv_suf_bits_len);
   }

   if (verbose) {
      printf("Before Entangle:\n");
      print_int_array("IV prefix bits", iv_pre_bits, iv_pre_bits_len);
      print_int_array("IV suffix bits", iv_suf_bits, iv_suf_bits_len);
   }

   /* entangle */
   p0 = p1 = p2 = 0;
   for (i = 0; i < 4; i++) { // 1 byte = 8 bits
      for (j = 0; j < 5; j++) {
         buffer_bits[p0++] = iv_pre_bits[p1++];
      }
      for (j = 0; j < 11; j++) {
         buffer_bits[p0++] = iv_suf_bits[p2++];
      }
   }
   if (verbose) {
      printf("After Entangle:\n");
      print_int_array("IV bits", buffer_bits, p0);
   }

   return bin_arr_to_char_arr(buffer_bits, p0, iv_out);
}

int encode_5bit(unsigned int *in,  int inlen,
                        char *out)
{
   int i, j, p, len, ret;
   unsigned int tmp[1024];
   unsigned char tmp2[1024];
   if (inlen % 5 != 0) {
      printf("Invalid input binary array length: %d\n", inlen);
      return -1;
   }

   p = 0;
   for (i = 0; i < inlen;) {
      for (j = 0; j < 3; j++)
        tmp[p++] = 0;

      for (j = 0; j < 5; j++)
        tmp[p++] = in[i++];
   }
   len = p;
   ret = bin_arr_to_char_arr(tmp, len, tmp2);
   if (ret != len / 8) {
      printf("Invalid char array lengh: %d\n", ret);
      return -1;
   }
   len = ret;
   for (i = 0; i < len; i++) {
      out[i] = encode_array[tmp2[i]];
   }
   out[i] = '\0';
   return i;
}

int decode_5bit(unsigned char *in,  int inlen,
                unsigned int *out, int *outlen)
{
    int i, j, out_len, r, err, p;
    int decode_array[512];
    unsigned int tmp[8];

    memset(decode_array, -1, sizeof(decode_array));
    for (i = 0; i < strlen(encode_array); i++) {
        decode_array[encode_array[i]] = i;
    }

    p = 0;
    for (i = 0; i < inlen; i++) {
        r = decode_array[in[i]];
        if (r == -1) {
          printf("failed to find symbol in decode array: %d\n", in[i]);
          return -1;
        }
        if ((err = int_to_bits(r, tmp, &out_len))!= 0) {
          printf("failed to convert int to bits\n");
          return -1;
        }
        if (out_len != 8) {
            printf("failed converting int to bits\n");
            return -1;
        }
        for (j = 3; j < 8; j++) {
            out[p++] = tmp[j];
        }
    }
    *outlen = p;
    return 0;
}

int extract_code_from_code_bits(unsigned int *code_bits,
                                         int bits_len,
                                         int reserved_bits,
                                unsigned char *encrypted_code,
                                unsigned long *encrypted_code_len)
{
    int i,len, ret;
    unsigned int tmp[512];

    for (i = reserved_bits; i < bits_len; i++) {
        tmp[i - reserved_bits] = code_bits[i];
    }
    len = i - reserved_bits;

    ret = bin_arr_to_char_arr(tmp, len, encrypted_code);
    if (ret != len / 8) {
       printf("Invalid char array lengh: %d\n", ret);
       return -1;
    }
    *encrypted_code_len = ret;

    return 0;
}

void decrypt_code(unsigned char *key, char *uuid, unsigned char *ciphertext)
{
   unsigned char raw_code[512], encrypted_code[512], cooked_encrypted_code[512], encoded_code[512];
   unsigned char IV[512], iv_pre[128], iv_suf[128], iv_suf_bytes[128];
   unsigned int cooked_encrypted_code_bits[512], iv_pre_bits[512], iv_suf_bits[512];
   int cooked_encrypted_code_bits_len;
   unsigned long cooked_encrypted_code_len, raw_code_len;
   int encoded_code_len, iv_prefix_size, iv_pre_bits_len, iv_suf_bits_len;
   int i, p, ret, len, err;
   symmetric_CTR ctr;

   if (verbose)
      printf("[Decrypting] UUID: %s, code: %s\n", uuid, ciphertext);

   len = strlen(ciphertext);
   p = 0;
   for (i = 0; i < len; i++) {
      if (ciphertext[i] == '-')
         continue;
      encoded_code[p++] = ciphertext[i];
   }
   encoded_code[p] = '\0';

   if (verbose) {
      printf("Removed '-': %s\n", encoded_code);
   }

   /* Decode */
   encoded_code_len = strlen(encoded_code);
   cooked_encrypted_code_bits_len = sizeof(cooked_encrypted_code_bits);
   if ((err = decode_5bit(encoded_code,
                          encoded_code_len,
                          cooked_encrypted_code_bits,
                          &cooked_encrypted_code_bits_len)) != CRYPT_OK) {
      printf("ctr_decode error\n");
      exit(-1);
   }

   /* Extract IV */
   iv_pre_bits_len = 20;
   for (i = 0; i < iv_pre_bits_len; i++) {
      iv_pre_bits[i] = cooked_encrypted_code_bits[i];
   }

   /* Get a bit array of IV template, longer than 44 */
   iv_suf_bits_len = 44;
   memcpy(iv_suf_bytes, iv_suf_template, strlen(iv_suf_template));
   ret = char_arr_to_bin_arr(iv_suf_bytes, strlen(iv_suf_bytes), iv_suf_bits);
   if (ret < iv_suf_bits_len) {
      printf("Not enough bits for IV suffix, expected: %d (actual %d)\n", iv_suf_bits_len, ret);
      exit(-1);
   }

   /* Setup IV*/
   ret = entangle_iv(iv_pre_bits, iv_pre_bits_len, iv_suf_bits, iv_suf_bits_len, IV);
   if (ret != ivsize) {
      printf("Error setting IV, expected: %d (actual: %d)\n", ivsize, ret);
      exit(-1);
   }

   if ((err = ctr_start(cipher_idx, IV, key, ks, 0, CTR_COUNTER_LITTLE_ENDIAN, &ctr)) != CRYPT_OK) {
      printf("ctr_start error: %s\n",error_to_string(err));
      exit(-1);
   }

   /* Extract encrypted code */
   if ((err = extract_code_from_code_bits(cooked_encrypted_code_bits,
                                          cooked_encrypted_code_bits_len,
                                          iv_pre_bits_len, encrypted_code,
                                          &raw_code_len)) != 0) {
      printf("failed extracting code from code bits\n");
      exit(-1);
   }

   /* Decrypt */
   if ((err = ctr_decrypt(encrypted_code, raw_code, raw_code_len, &ctr)) != CRYPT_OK) {
      printf("ctr_decrypt error: %s\n", error_to_string(err));
      exit(-1);
   }

   /* Print raw code with Base32 bacause it contains unprintalbe characters */
   print_raw_code(raw_code);
}

void encrypt_code(unsigned char *key, char *uuid)
{
   uint64_t systime;
   unsigned char raw_code[512], encrypted_code[512], encoded_code[512];
   unsigned char final_code[512];
   unsigned char IV[512], iv_pre_bytes[128], iv_suf_bytes[128];
   unsigned int iv_pre_bits[512], iv_suf_bits[512], cooked_encrypted_code_bits[512], encrypted_code_bits[512];
   unsigned long cooked_encrypted_code_bits_len, encoded_code_len;
   int raw_code_len, iv_prefix_overhead_size, iv_pre_bits_len, iv_suf_bits_len;
   int i, p, ret, err, encrypted_code_bits_len;
   prng_state prng;
   symmetric_CTR ctr;

   systime = getCurrentTime();

   if (verbose)
      printf("[Encrypting] UUID: %s, systime: %Ld\n", uuid, systime);

   /* Get Raw code */
   raw_code_len = get_raw_code(uuid, systime, raw_code);
   if (verbose) {
      printf("Raw code len: %d\n", raw_code_len);
   }

   /* Setup yarrow for random bytes for IV */
   if ((err = rng_make_prng(128, find_prng("yarrow"), &prng, NULL)) != CRYPT_OK) {
      printf("Error setting up PRNG, %s\n", error_to_string(err));
   }

   /* You can use rng_get_bytes on platforms that support it */
   /* ret = rng_get_bytes(IV,ivsize,NULL);*/
   iv_prefix_overhead_size = 3;
   iv_pre_bits_len = 20;
   ret = yarrow_read(iv_pre_bytes, iv_prefix_overhead_size, &prng);
   if (ret != iv_prefix_overhead_size) {
      printf("Error reading PRNG for IV required.\n");
      exit(-1);
   }

   /* Get a bit array longer than 20 */
   ret = char_arr_to_bin_arr(iv_pre_bytes, iv_prefix_overhead_size, iv_pre_bits);
   if (ret < iv_pre_bits_len) {
      printf("Not enough bits for IV prefix, expected: %d (actual %d)\n", iv_pre_bits_len, ret);
      exit(-1);
   }

   /* Get a bit array of IV template, longer than 44 */
   iv_suf_bits_len = 44;
   memcpy(iv_suf_bytes, iv_suf_template, strlen(iv_suf_template));
   ret = char_arr_to_bin_arr(iv_suf_bytes, strlen(iv_suf_bytes), iv_suf_bits);
   if (ret < iv_suf_bits_len) {
      printf("Not enough bits for IV suffix, expected: %d (actual %d)\n", iv_suf_bits_len, ret);
      exit(-1);
   }

   /* Setup IV*/
   ret = entangle_iv(iv_pre_bits, iv_pre_bits_len, iv_suf_bits, iv_suf_bits_len, IV);
   if (ret != ivsize) {
      printf("Error setting IV, expected: %d (actual: %d)\n", ivsize, ret);
      exit(-1);
   }

   if ((err = ctr_start(cipher_idx, IV, key, ks, 0, CTR_COUNTER_LITTLE_ENDIAN, &ctr)) != CRYPT_OK) {
      printf("ctr_start error: %s\n",error_to_string(err));
      exit(-1);
   }

   /* Print raw code with Base32 bacause it contains unprintalbe characters */
   if (verbose)
      print_raw_code(raw_code);

   /* Encrypt */
   if ((err = ctr_encrypt(raw_code, encrypted_code, raw_code_len, &ctr)) != CRYPT_OK) {
      printf("ctr_encrypt error: %s\n", error_to_string(err));
      exit(-1);
   }

   /* Convert encrypted code from bytes to bits */
   ret = char_arr_to_bin_arr(encrypted_code, raw_code_len, encrypted_code_bits);
   if (ret != raw_code_len * 8) {
      printf("failed to convert encrypted code to bits\n");
      exit(-1);
   }
   encrypted_code_bits_len = ret;

   /* Cook, add IV bits as prefix */
   for (i = 0; i < iv_pre_bits_len; i++) {
      cooked_encrypted_code_bits[i] = iv_pre_bits[i];
   }
   for (i = 0; i < encrypted_code_bits_len; i++) {
      cooked_encrypted_code_bits[i + iv_pre_bits_len] = encrypted_code_bits[i];
   }
   cooked_encrypted_code_bits_len = i + iv_pre_bits_len;
   if (cooked_encrypted_code_bits_len != 100) {
      printf("Invalid cooked encrypted code bits len: %d\n", cooked_encrypted_code_bits_len);
      exit(-1);
   }

   /* 5-bit Encode */
   encoded_code_len = encode_5bit(cooked_encrypted_code_bits, cooked_encrypted_code_bits_len, encoded_code);
   if (verbose) {
      printf("Encoded: %s, len: %d\n", encoded_code, encoded_code_len);
   }

   // Format code
   p = 0;
   for (i = 0; i < encoded_code_len; i++) {
      final_code[p++] = encoded_code[i];
      if ((i + 1) % 5 == 0 && (i + 1) != encoded_code_len) {
         final_code[p++] = '-';
      }
   }
   final_code[p] = '\0';
   printf("[CODE] %s\n", final_code);
}

int main(int argc, char *argv[])
{
   const char *key_prefix = "Request";
   unsigned char tmpkey[512], key[512];
   char *uuid, *plaintext, *ciphertext;
   int decrypt, err;
   unsigned long outlen;

   /* register algs, so they can be printed */
   register_all_ciphers();
   register_all_hashes();
   register_all_prngs();

   if (argc < 3) {
      return usage(argv[0]);
   }

   /* Handle arguments */
   if (!strcmp(argv[1], "-d")) {
      decrypt = 1;
      uuid  = argv[2];
      ciphertext = argv[3];
   } else if (!strcmp(argv[1], "-e")) {
      decrypt = 0;
      uuid  = argv[2];
   } else {
      printf("invalid option %s (expected -e or -d)\n", argv[1]);
      exit(-1);
   }

   /* Set verbose */
   if (strcmp(argv[argc - 1], "-v") == 0 || strcmp(argv[argc - 1], "--verbose") == 0) {
      verbose = 1;
   }

   if (verbose)
      printf("UUID: %s\n", uuid);

   cipher_idx = find_cipher(cipher);
   if (cipher_idx == -1) {
      printf("Invalid cipher entered on command line.\n");
      exit(-1);
   }

   hash_idx = find_hash("sha256");
   if (hash_idx == -1) {
      printf("LTC_SHA256 not found...?\n");
      exit(-1);
   }

   ivsize = cipher_descriptor[cipher_idx].block_length;
   ks = hash_descriptor[hash_idx].hashsize;
   if (cipher_descriptor[cipher_idx].keysize(&ks) != CRYPT_OK) {
      printf("Invalid keysize???\n");
      exit(-1);
   }

   memcpy(tmpkey, key_prefix, strlen(key_prefix));
   substring(uuid, tmpkey, 0, 16, strlen(key_prefix)); // Pick index 0 ~ 15 of uuid as key
   if (verbose) {
      printf("Encryption key (Before Hash): %s\n", tmpkey);
   }
   outlen = sizeof(key);
   if ((err = hash_memory(hash_idx, tmpkey, strlen((char *)tmpkey), key, &outlen)) != CRYPT_OK) {
      printf("Error hashing key: %s\n", error_to_string(err));
      exit(-1);
   }

   if (decrypt) {
      decrypt_code(key, uuid, ciphertext);
   } else {
      encrypt_code(key, uuid);
   }

   return 0;
}
