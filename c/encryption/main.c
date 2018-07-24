#include <tomcrypt.h>

int usage(char *name)
{
   int x;

   printf("Usage encrypt: %s cipher infile outfile\n", name);
   printf("Usage decrypt: %s -d cipher infile outfile\n", name);
   printf("Usage test:    %s -t cipher\nCiphers:\n", name);
   for (x = 0; cipher_descriptor[x].name != NULL; x++) {
      printf("%s\n",cipher_descriptor[x].name);
   }
   exit(1);
}

int main(int argc, char *argv[])
{
   unsigned char plaintext[512],ciphertext[512], BUFFER[1024];
   unsigned char tmpkey[512], key[MAXBLOCKSIZE], IV[MAXBLOCKSIZE], tmp[512];
   unsigned char inbuf[512]; /* i/o block size */
   unsigned long outlen, y, ivsize, x, decrypt, tmp_len, textlen;
   symmetric_CTR ctr;
   int cipher_idx, hash_idx, ks;
   char *cipher, *input;
   int err, i, reserved_len;
   prng_state prng;
   const char *global_key = "161a9d1c15d5esdf";
   const char *random_array = "ybndrfg8ejkmcpqxot1uwisza345h769";

   /* register algs, so they can be printed */
   register_all_ciphers();
   register_all_hashes();
   register_all_prngs();

   reserved_len = 2;
   textlen = 13;

   if (argc < 3) {
      if ((argc > 2) && (!strcmp(argv[1], "-t"))) {
        cipher  = argv[2];
        cipher_idx = find_cipher(cipher);
        if (cipher_idx == -1) {
          printf("Invalid cipher %s entered on command line.\n", cipher);
          exit(-1);
        } /* if */
        if (cipher_descriptor[cipher_idx].test)
        {
          if (cipher_descriptor[cipher_idx].test() != CRYPT_OK)
          {
            printf("Error when testing cipher %s.\n", cipher);
            exit(-1);
          }
          else
          {
            printf("Testing cipher %s succeeded.\n", cipher);
            exit(0);
          } /* if ... else */
        } /* if */
      }
      return usage(argv[0]);
   }

   if (!strcmp(argv[1], "-d")) {
      decrypt = 1;
      cipher = argv[2];
      input = argv[3];
   } else {
      decrypt = 0;
      cipher = argv[1];
      input = argv[2];
   }

   y = strlen(input);
   printf("input: %s, len: %d\n", input, y);

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

   // Set key
   memcpy(tmpkey, global_key, strlen(global_key));

   outlen = sizeof(key);
   if ((err = hash_memory(hash_idx,tmpkey,strlen((char *)tmpkey),key,&outlen)) != CRYPT_OK) {
      printf("Error hashing key: %s\n", error_to_string(err));
      exit(-1);
   }

   if (strlen((char *) key) != ks) {
      printf("Error setting key, expected len: %d (actual: %d)\n", ks, strlen((char *) key));
      exit(-1);
   }

   printf("Use key len: %d\n", ks);

   if (decrypt) {
      tmp_len = sizeof(tmp);
      if ((err = base32_decode(input, y, tmp, &tmp_len, BASE32_CROCKFORD)) != CRYPT_OK) {
         printf("ctr_decode error: %s\n", error_to_string(err));
         return -1;
      }

      memcpy(BUFFER, tmp, strlen((char *) tmp));
      y = strlen((char *) BUFFER);
      printf("After decode, len: %d\n", y);

      for (i = 0; i < reserved_len; i++) {
         IV[i] = BUFFER[i];
      }
      for (i = reserved_len; i < ivsize; i++) {
         IV[i] = 'a';
      }
      IV[ivsize] = '\0';

      if (strlen((char *)IV) != ivsize) {
         printf("Error setting IV, expected: %d (actual: %d).\n", ivsize, strlen((char *)IV));
         exit(-1);
      }

      if ((err = ctr_start(cipher_idx,IV,key,ks,0,CTR_COUNTER_LITTLE_ENDIAN,&ctr)) != CRYPT_OK) {
         printf("ctr_start error: %s\n",error_to_string(err));
         exit(-1);
      }

      y -= reserved_len;
      for (i = 0; i < y; i++) {
         inbuf[i] = BUFFER[i + reserved_len];
      }
      inbuf[y] = '\0';
      if (strlen((char *)inbuf) != textlen) {
         printf("Error setting inbuf, expected: %d (actual: %d).\n", textlen, strlen((char *)inbuf));
         exit(-1);
      }
      y = textlen;

      if ((err = ctr_decrypt(inbuf,plaintext,y,&ctr)) != CRYPT_OK) {
         printf("ctr_decrypt error: %s\n", error_to_string(err));
         exit(-1);
      }
      printf("After decrypt: %s, len: %d\n", plaintext, strlen((char * ) plaintext));

   } else {  /* encrypt */
      if ((err = rng_make_prng(128, find_prng("yarrow"), &prng, NULL)) != CRYPT_OK) {
         printf("Error setting up PRNG, %s\n", error_to_string(err));
      }

      /* You can use rng_get_bytes on platforms that support it */
      x = rng_get_bytes(IV,reserved_len,NULL);
      // x = yarrow_read(IV,reserved_len,&prng);
      if (x != reserved_len) {
         printf("Error reading PRNG for IV required.\n");
         exit(-1);
      }

      for (i = reserved_len; i < ivsize; i++) {
         IV[i] = 'a';
      }
      IV[ivsize] = '\0';
      if (strlen((char *) IV) != ivsize) {
         printf("Error set IV len, expected: %d (actual: %d).\n", ivsize, strlen((char *) IV));
         exit(-1);
      }
      printf("IV len: %d\n", strlen((char *) IV));

      if ((err = ctr_start(cipher_idx,IV,key,ks,0,CTR_COUNTER_LITTLE_ENDIAN,&ctr)) != CRYPT_OK) {
         printf("ctr_start error: %s\n",error_to_string(err));
         exit(-1);
      }

      memcpy(inbuf, input, strlen((char *) input));
      y = strlen((char *) inbuf);
      printf("Before encryption, len: %d\n", y);

      if ((err = ctr_encrypt(inbuf,ciphertext,y,&ctr)) != CRYPT_OK) {
         printf("ctr_encrypt error: %s\n", error_to_string(err));
         exit(-1);
      }

      y = strlen((char *) ciphertext);
      printf("After encryption, len: %d\n", y);

      // Concat
      for (i = 0; i < reserved_len; i++) {
         BUFFER[i] = IV[i];
      }
      for (i = 0; i < y; i++) {
         BUFFER[i + reserved_len] = ciphertext[i];
      }
      BUFFER[reserved_len + y] = '\0';

      if ((reserved_len + y) != strlen((char *) BUFFER)) {
         printf("ctr_concat error, expected: %d (actual: %d)\n", reserved_len + y, strlen((char *) BUFFER));
         exit(-1);
      }

      tmp_len = sizeof(tmp);
      if ((err = base32_encode(BUFFER, reserved_len + y, tmp, &tmp_len, BASE32_CROCKFORD)) != CRYPT_OK) {
         printf("ctr_encode error: %s\n", error_to_string(err));
         return -1;
      }
      printf("After encode: %s, len: %Ld\n", tmp, tmp_len);
   }

   /* terminate the stream */
   if ((err = ctr_done(&ctr)) != CRYPT_OK) {
      printf("ctr_done error: %s\n", error_to_string(err));
      return -1;
   }

   /* clear up and return */
   zeromem(key, sizeof(key));
   zeromem(&ctr, sizeof(ctr));
   return 0;
}
