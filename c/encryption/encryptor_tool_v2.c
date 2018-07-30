#include <tomcrypt.h>
#include <stdlib.h>
#include <sys/time.h>
#include <stdint.h>
#include <string.h>

/*
 * Compile:
 *     make
 *
 * Usage: ./encryptor_tool_v2.o -e 161a9d1c6b434e998e52e5be7356e438 -v
 *         IV: 1110010100000011101101000001000111110100010011011110010101010000
 *   Raw Code: 64V32R9SCGRP6
 * Final Code: W2RZ9-SBRXW-B5GY4-9H2AG
 *        ./encryptor_tool_v2.o -d 161a9d1c6b434e998e52e5be7356e438 W2RZ9-SBRXW-B5GY4-9H2AG -v
 *   Raw Code: 64V32R9SCGRP6
 *
 */

int verbose = 0;
const unsigned char *iv_suf_template = "SAMPLEIVSUFFIX";
const char *cipher = "blowfish";
int cipher_idx, hash_idx, ks, ivsize;

int usage(char *name)
{
   int x;

   printf("Usage encrypt: %s -e uuid\n", name);
   printf("Usage decrypt: %s -d uuid ciphertext(Base32)\n", name);
   exit(1);
}

void print_int_array(const char *title, int *arr, int len)
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

void int64_to_bin_digit(uint64_t in, unsigned char *out, int nbytes)
{
    int i;

    for (i = 0; i < nbytes; i++) {
        out[i] = in >> ((nbytes - i - 1) * 8);
    }
}

int get_raw_code(char *uuid, unsigned char *out)
{
    const int use_first_n = 8;
    int i, len;
    int buffer_len = use_first_n + 1;

    if (strlen(uuid) != 32) {
        printf("invalid UUID: %s\n", uuid);
        exit(-1);
    }

    // Use first 8 characters of uuid
    for (i = 0; i < use_first_n; i++) {
        out[i] = uuid[i];
    }
    out[i] = '\0';

    return strlen(out);
}

void substring(char *in, unsigned char *out, int start_Index, int end_index)
{
   int total_len;
   int i, j;

   total_len = strlen(in);
   if (end_index > total_len) {
      printf("invalid end index: %d\n", end_index);
      return;
   }
   if (start_Index < 0) {
      printf("invalid start index: %d\n", start_Index);
      return;
   }

   j = 0;
   for (i = start_Index; i < end_index; i++) {
      out[j++] = in[i];
   }
   out[j] = '\0';
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

int entangle_iv(unsigned char *iv_pre, int iv_pre_bytes_len, unsigned char *iv_suf, int iv_suf_bytes_len, unsigned char *iv_out)
{
   int iv_pre_bits[1024], iv_suf_bits[1024], buffer_bits[2048];
   int iv_pre_bits_len, iv_suf_bits_len;
   int i, j, p0, p1, p2;
   int ret;

   if (verbose) {
      printf("IV prefix len: %d, IV suffix len: %d\n", iv_pre_bytes_len, iv_suf_bytes_len);
   }

   /* Convert to bits */
   iv_pre_bits_len = char_arr_to_bin_arr(iv_pre, iv_pre_bytes_len, iv_pre_bits);
   iv_suf_bits_len = char_arr_to_bin_arr(iv_suf, iv_suf_bytes_len, iv_suf_bits);

   if (verbose) {
      printf("Before Entangle:\n");
      print_int_array("IV prefix bits", iv_pre_bits, iv_pre_bits_len);
      print_int_array("IV suffix bits", iv_suf_bits, iv_suf_bits_len);
   }

   /* entangle */
   p0 = p1 = p2 = 0;
   for (i = 0; i < 8; i++) { // 1 byte = 8 bits
      for (j = 0; j < iv_pre_bytes_len; j++) {
         buffer_bits[p0++] = iv_pre_bits[p1++];
      }
      for (j = 0; j < iv_suf_bytes_len; j++) {
         buffer_bits[p0++] = iv_suf_bits[p2++];
      }
   }
   if (verbose) {
      printf("After Entangle:\n");
      print_int_array("IV bits", buffer_bits, p0);
   }

   ret = bin_arr_to_char_arr(buffer_bits, p0, iv_out);
   return ret;
}

void print_raw_code(unsigned char *raw_code)
{
   unsigned char encoded_code[512];
   unsigned long raw_code_len, encoded_code_len;
   int err;

   encoded_code_len = sizeof(encoded_code);
   raw_code_len = strlen((char *) raw_code);
   if ((err = base32_encode(raw_code, raw_code_len, encoded_code, &encoded_code_len, BASE32_CROCKFORD)) != CRYPT_OK) {
      printf("base32 encode error: %s\n", error_to_string(err));
      exit(-1);
   }
   printf("[Raw code] %s\n", encoded_code);
}

void decrypt_code(unsigned char *key, char *uuid, unsigned char *ciphertext)
{
   unsigned char raw_code[512], encrypted_code[512], cooked_encrypted_code[512], encoded_code[512];
   unsigned char IV[512], iv_pre[128], iv_suf[128];
   unsigned long cooked_encrypted_code_len, raw_code_len;
   int encoded_code_len, iv_prefix_size;
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
   cooked_encrypted_code_len = sizeof(cooked_encrypted_code);
   if ((err = base32_decode(encoded_code, encoded_code_len, cooked_encrypted_code, &cooked_encrypted_code_len, BASE32_CROCKFORD)) != CRYPT_OK) {
      printf("ctr_decode error: %s\n", error_to_string(err));
      exit(-1);
   }

   /* Extract IV */
   iv_prefix_size = 4;
   for (i = 0; i < iv_prefix_size; i++) {
      iv_pre[i] = cooked_encrypted_code[i];
   }
   iv_pre[i] = '\0';

   for (i = 0; i < ivsize - iv_prefix_size && i < strlen(iv_suf_template); i++) {
      iv_suf[i] = iv_suf_template[i];
   }
   iv_suf[i] = '\0';

   /* Setup IV*/
   ret = entangle_iv(iv_pre, iv_prefix_size, iv_suf, i, IV);
   if (ret != ivsize) {
      printf("Error setting IV\n");
      exit(-1);
   }

   if ((err = ctr_start(cipher_idx, IV, key, ks, 0, CTR_COUNTER_LITTLE_ENDIAN, &ctr)) != CRYPT_OK) {
      printf("ctr_start error: %s\n",error_to_string(err));
      exit(-1);
   }

   /* Extract encrypted code */
   p = 0;
   for (i = iv_prefix_size; i < cooked_encrypted_code_len; i++) {
      encrypted_code[p++] = cooked_encrypted_code[i];
   }
   raw_code_len = p;

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
   unsigned char raw_code[512], encrypted_code[512], cooked_encrypted_code[512], encoded_code[512];
   unsigned char final_code[512];
   unsigned char IV[512], iv_pre[128], iv_suf[128];
   unsigned long cooked_encrypted_code_len, encoded_code_len;
   int raw_code_len, iv_prefix_size;
   int i, p, ret, err, len;
   prng_state prng;
   symmetric_CTR ctr;
   unsigned char *time_bytes;

   systime = getCurrentTime();

   if (verbose)
      printf("[Encrypting] UUID: %s, systime: %Ld\n", uuid, systime);

   /* Get Raw code */
   raw_code_len = get_raw_code(uuid, raw_code);
   if (verbose)
      printf("Raw code len: %d\n", raw_code_len);

   /* Get last 4 bytes of system time */
   len = sizeof(systime);
   time_bytes = malloc(sizeof(unsigned char) * len);
   int64_to_bin_digit(systime, time_bytes, len);
   if (verbose)
      print_unchar_array("System time bytes:", time_bytes, len);

   iv_prefix_size = 4;
   for (i = 0; i < iv_prefix_size; i++) {
      iv_pre[i] = time_bytes[len - i - 1];
   }

   for (i = 0; i < ivsize - iv_prefix_size && i < strlen(iv_suf_template); i++) {
      iv_suf[i] = iv_suf_template[i];
   }
   iv_suf[i] = '\0';

   /* Setup IV*/
   ret = entangle_iv(iv_pre, iv_prefix_size, iv_suf, i, IV);
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

   /* Cook, add IV as prefix */
   for (i = 0; i < iv_prefix_size; i++) {
      cooked_encrypted_code[i] = iv_pre[i];
   }
   for (i = 0; i < raw_code_len; i++) {
      cooked_encrypted_code[i + iv_prefix_size] = encrypted_code[i];
   }

   /* Encode with Base32 */
   encoded_code_len = sizeof(encoded_code);
   cooked_encrypted_code_len = raw_code_len + iv_prefix_size;
   if ((err = base32_encode(cooked_encrypted_code, cooked_encrypted_code_len, encoded_code, &encoded_code_len, BASE32_CROCKFORD)) != CRYPT_OK) {
      printf("base32 encode error: %s\n", error_to_string(err));
      exit(-1);
   }
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

   substring(uuid, tmpkey, 0, 16); // Pick index 0 ~ 15 of uuid as key
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
