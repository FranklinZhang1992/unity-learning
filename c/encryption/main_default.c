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
   unsigned char plaintext[512],ciphertext[512],tmp[512];
   unsigned char tmpkey[512], key[MAXBLOCKSIZE], IV[MAXBLOCKSIZE];
   unsigned char inbuf[512]; /* i/o block size */
   unsigned long outlen, y, ivsize, x, decrypt, reserved_size, tmp_len;
   symmetric_CTR ctr;
   int cipher_idx, hash_idx, ks;
   char *infile, *outfile, *cipher;
   prng_state prng;
   FILE *fdin, *fdout;
   int err, i;
   const char *global_key = "161a9d1c15d5esdf";

   reserved_size = 2;

   /* register algs, so they can be printed */
   register_all_ciphers();
   register_all_hashes();
   register_all_prngs();

   if (argc < 4) {
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
      cipher  = argv[2];
      infile  = argv[3];
      outfile = argv[4];
   } else {
      decrypt = 0;
      cipher  = argv[1];
      infile  = argv[2];
      outfile = argv[3];
   }

   /* file handles setup */
   fdin = fopen(infile,"rb");
   if (fdin == NULL) {
      perror("Can't open input for reading");
      exit(-1);
   }

   fdout = fopen(outfile,"wb");
   if (fdout == NULL) {
      perror("Can't open output for writing");
      exit(-1);
   }

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


   memcpy(tmpkey, global_key, strlen(global_key));
   outlen = sizeof(key);
   if ((err = hash_memory(hash_idx,tmpkey,strlen((char *)tmpkey),key,&outlen)) != CRYPT_OK) {
      printf("Error hashing key: %s\n", error_to_string(err));
      exit(-1);
   }

   if (decrypt) {
      /* Need to read in IV */
      if (fread(IV,1,reserved_size,fdin) != reserved_size) {
         printf("Error reading IV from input.\n");
         exit(-1);
      }
      for (i = reserved_size; i < ivsize; i++) {
         IV[i] = 'a';
      }
      IV[ivsize] = '\0';

      if ((err = ctr_start(cipher_idx,IV,key,ks,0,CTR_COUNTER_LITTLE_ENDIAN,&ctr)) != CRYPT_OK) {
         printf("ctr_start error: %s\n",error_to_string(err));
         exit(-1);
      }

      /* IV done */
      do {
         y = fread(inbuf,1,sizeof(inbuf),fdin);

         if ((err = ctr_decrypt(inbuf,plaintext,y,&ctr)) != CRYPT_OK) {
            printf("ctr_decrypt error: %s\n", error_to_string(err));
            exit(-1);
         }

         if (fwrite(plaintext,1,y,fdout) != y) {
            printf("Error writing to file.\n");
            exit(-1);
         }
         printf("After decrypt: %s, len: %d\n", plaintext, strlen((char *) plaintext));
      } while (y == sizeof(inbuf));
      fclose(fdin);
      fclose(fdout);

   } else {  /* encrypt */
      /* Setup yarrow for random bytes for IV */

      if ((err = rng_make_prng(128, find_prng("yarrow"), &prng, NULL)) != CRYPT_OK) {
         printf("Error setting up PRNG, %s\n", error_to_string(err));
      }

      /* You can use rng_get_bytes on platforms that support it */
      /* x = rng_get_bytes(IV,ivsize,NULL);*/
      x = yarrow_read(IV,reserved_size,&prng);
      if (x != reserved_size) {
         printf("Error reading PRNG for IV required.\n");
         exit(-1);
      }

      if (fwrite(IV,1,reserved_size,fdout) != reserved_size) {
         printf("Error writing IV to output.\n");
         exit(-1);
      }
      for (i = reserved_size; i < ivsize; i++) {
         IV[i] = 'a';
      }
      IV[ivsize] = '\0';

      if ((err = ctr_start(cipher_idx,IV,key,ks,0,CTR_COUNTER_LITTLE_ENDIAN,&ctr)) != CRYPT_OK) {
         printf("ctr_start error: %s\n",error_to_string(err));
         exit(-1);
      }

      do {
         y = fread(inbuf,1,sizeof(inbuf),fdin);

         if ((err = ctr_encrypt(inbuf,ciphertext,y,&ctr)) != CRYPT_OK) {
            printf("ctr_encrypt error: %s\n", error_to_string(err));
            exit(-1);
         }

         if (fwrite(ciphertext,1,y,fdout) != y) {
            printf("Error writing to output.\n");
            exit(-1);
         }
      } while (y == sizeof(inbuf));
      fclose(fdout);
      fclose(fdin);

      fdin = fopen(outfile,"rb");
      if (fdin == NULL) {
         perror("Can't open output for reading");
         exit(-1);
      }
      y = fread(inbuf,1,sizeof(inbuf),fdin);

      tmp_len = sizeof(tmp);
      if ((err = base32_encode(inbuf, y, tmp, &tmp_len, BASE32_CROCKFORD)) != CRYPT_OK) {
         printf("ctr_encode error: %s\n", error_to_string(err));
         return -1;
      }
      printf("Encoded: %s, len: %d\n", tmp, strlen((char *) tmp));
   }
   return 0;
}