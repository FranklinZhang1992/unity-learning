#include <tomcrypt.h>

int test_blowfish_ecb(unsigned char *plaintext)
{
    int key_len = 16;
    unsigned char pt[40], ct[40], key[key_len + 1], tmp[1024];
    symmetric_key skey;
    int err;
    unsigned long tmp_len = sizeof(tmp);
    unsigned long ct_len = sizeof(ct);

    strcpy((char*) key, "161a9d1c6b434e99");
    strcpy((char*) pt, plaintext);
    printf("Encrypting for %s, length = %d\n", pt, strlen(pt));

    printf("key length = %d\n", strlen(key));

    if ((err = blowfish_setup(key, /* the key we will use */
                          key_len, /* key is 8 bytes (64-bits) long */
                                0, /* 0 == use default # of rounds */
                            &skey) /* where to put the scheduled key */
        ) != CRYPT_OK) {
        printf("Setup error: %s\n", error_to_string(err));
        return -1;
    }
    /* encrypt the block */
    blowfish_ecb_encrypt(pt, /* encrypt this 8-byte array */
                         ct, /* store encrypted data here */
                     &skey); /* our previously scheduled key */

    /* now ct holds the encrypted version of pt */
    ct_len = strlen(ct);
    printf("After encrypt, length = %d\n", ct_len);
    if ((err = base32_encode(ct, ct_len, tmp, &tmp_len, BASE32_CROCKFORD)) != CRYPT_OK) {
        printf("ctr_encrypt error: %s\n", error_to_string(err));
        return -1;
    }

    printf("After encode: %s, length = %d\n", tmp, tmp_len);
    if ((err = base32_decode(tmp, tmp_len, ct, &ct_len, BASE32_CROCKFORD)
        ) != CRYPT_OK) {
        printf("ctr_encrypt error: %s\n", error_to_string(err));
        return -1;
    }
    printf("After decode, length = %d\n", ct_len);

    /* decrypt the block */
    blowfish_ecb_decrypt(ct, /* decrypt this 8-byte array */
                         pt, /* store decrypted data here */
                     &skey); /* our previously scheduled key */
    printf("After decrypt: %s, length = %d\n", pt, strlen(pt));

    /* now we have decrypted ct to the original plaintext in pt */

    /* Terminate the cipher context */
    blowfish_done(&skey);

    printf("#########################################################\n");
    return 0;
}

int blowfish_keysize_test(int attempt_key_size)
{
    int keysize, err;
    /* now given a 20 byte key what keysize does blowfish want to use? */
    keysize = attempt_key_size;
    if ((err = blowfish_keysize(&keysize)) != CRYPT_OK) {
        printf("Error getting key size: %s\n", error_to_string(err));
        return -1;
    }
    printf("Blowfish suggested a key size of %d\n", keysize);
    return 0;
}

int test_rc4(unsigned char *plaintext)
{
    rc4_state st;
    unsigned char key[20], in_buffer[1024], out_buffer[1024], tmp[1024];
    unsigned long key_len, in_len, out_len, tmp_len;
    int err;

    sscanf(plaintext,"%s", &in_buffer);
    in_len = strlen(in_buffer);

    sscanf("297PGx103ahJ","%s", &key);
    key_len = strlen(key);
    printf("key: %s, len: %Ld\n", key, key_len);


    // Encryption

    if ((err = rc4_stream_setup(&st, key, key_len)) != CRYPT_OK) {
        printf("rc4_encrypt error: %s\n", error_to_string(err));
        return -1;
    }

    printf("Before encryption: %s, len: %Ld\n", in_buffer, in_len);
    if ((err = rc4_stream_crypt(&st, in_buffer, in_len, out_buffer)) != CRYPT_OK) {
        printf("rc4_encrypt error: %s\n", error_to_string(err));
        return -1;
    }
    out_len = strlen(out_buffer);
    printf("After encryption, length = %Ld\n", out_len);

    if ((err = rc4_stream_done(&st)) != CRYPT_OK) {
        printf("rc4_encrypt error: %s\n", error_to_string(err));
        return -1;
    }

    tmp_len = 30;
    if ((err = base32_encode(out_buffer, out_len, tmp, &tmp_len, BASE32_CROCKFORD)) != CRYPT_OK) {
        printf("rc4_encrypt error: %s\n", error_to_string(err));
        return -1;
    }
    printf("After encode: %s, len: %Ld\n", tmp, tmp_len);

    if ((err = base32_decode(tmp, tmp_len, in_buffer, &in_len, BASE32_CROCKFORD)
        ) != CRYPT_OK) {
        printf("rc4_encrypt error: %s\n", error_to_string(err));
        return -1;
    }
    printf("After decode, length = %d\n", in_len);


    // Decryption

    if ((err = rc4_stream_setup(&st, key, key_len)) != CRYPT_OK) {
        printf("rc4_encrypt error: %s\n", error_to_string(err));
        return -1;
    }

    if ((err = rc4_stream_crypt(&st, in_buffer, in_len, out_buffer)) != CRYPT_OK) {
        printf("rc4_encrypt error: %s\n", error_to_string(err));
        return -1;
    }

    out_len = strlen(out_buffer);
    printf("After decryption: %s, len: %Ld\n", out_buffer, out_len);

    if ((err = rc4_stream_done(&st)) != CRYPT_OK) {
        printf("rc4_encrypt error: %s\n", error_to_string(err));
        return -1;
    }

    printf("#########################################################\n");
    return 0;
}

int test_aes_ctr(unsigned char *plaintext)
{
    symmetric_CTR ctr;
    unsigned char key[1024], IV[1024], in_buffer[1024], out_buffer[1024], tmp[1024];
    unsigned long key_len, iv_len, in_len, out_len, tmp_len;
    int err;

    sscanf(plaintext,"%s", &in_buffer);
    in_len = strlen(in_buffer) + 1;

    sscanf("161a9d1c6b434e99","%s", &key);
    key_len = strlen((char *)key);

    sscanf("8e52e5be7356e438","%s", &IV);
    iv_len = strlen((char *)IV);

    printf("key: %s, len: %Ld, iv: %s, len: %Ld\n", key, key_len, IV, iv_len);

    if (register_cipher(&aes_desc) == -1) {
        printf("Unable to register AES cipher.");
        return -1;
    }

    if ((err = ctr_start(find_cipher("aes"), IV, key, 16, 0, CTR_COUNTER_LITTLE_ENDIAN, &ctr)) != CRYPT_OK) {
        printf("ctr_start error: %s\n", error_to_string(err));
        return -1;
    }

    printf("Before encryption: %s, len: %Ld\n", in_buffer, in_len);
    if ((err = ctr_encrypt(in_buffer, out_buffer, in_len, &ctr)) != CRYPT_OK) {
        printf("ctr_encrypt error: %s\n", error_to_string(err));
        return -1;
    }
    out_len = strlen(out_buffer);
    printf("After encryption, length = %Ld\n", out_len);

    tmp_len = 1000;
    if ((err = base64_encode(out_buffer, out_len, tmp, &tmp_len)) != CRYPT_OK) {
        printf("ctr_encode error: %s\n", error_to_string(err));
        return -1;
    }
    printf("After encode: %s, len: %Ld\n", tmp, tmp_len);

    in_len = out_len + 1;
    if ((err = base64_decode(tmp, tmp_len, in_buffer, &in_len)
        ) != CRYPT_OK) {
        printf("ctr_decode error: %s\n", error_to_string(err));
        return -1;
    }
    printf("After decode, length = %d\n", in_len);


    if ((err = ctr_setiv( IV, 16, &ctr)) != CRYPT_OK) {
        printf("ctr_setiv error: %s\n", error_to_string(err));
        return -1;
    }

    if ((err = ctr_decrypt(in_buffer, out_buffer, sizeof(in_buffer), &ctr)) != CRYPT_OK) {
        printf("ctr_decrypt error: %s\n", error_to_string(err));
        return -1;
    }

    out_len = strlen(out_buffer);
    printf("After decryption: %s, len: %Ld\n", out_buffer, out_len);

    if ((err = ctr_done(&ctr)) != CRYPT_OK) {
        printf("ctr_done error: %s\n", error_to_string(err));
        return -1;
    }

    zeromem(key, sizeof(key));
    zeromem(IV, sizeof(IV));
    zeromem(&ctr, sizeof(ctr));

    printf("#########################################################\n");
    return 0;
}

int test_blowfish_ctr(unsigned char *plaintext)
{
    symmetric_CTR ctr;
    unsigned char key[16], IV[16], in_buffer[16], out_buffer[16], tmp[1024];
    unsigned long key_len, iv_len, in_len, out_len, tmp_len;
    int err;

    sscanf(plaintext,"%s", &in_buffer);
    in_len = strlen(in_buffer);

    sscanf("161a9d1c6b434e99","%s", &key);
    key_len = strlen(key);

    sscanf("8e52e5be7356e438","%s", &IV);
    iv_len = strlen(IV);

    printf("key: %s, len: %Ld, iv: %s, len: %Ld\n", key, key_len, IV, iv_len);

    if (register_cipher(&aes_desc) == -1) {
        printf("Unable to register AES cipher.");
        return -1;
    }

    if ((err = ctr_start(find_cipher("aes"), IV, key, 16, 0, CTR_COUNTER_LITTLE_ENDIAN, &ctr)) != CRYPT_OK) {
        printf("ctr_start error: %s\n", error_to_string(err));
        return -1;
    }

    printf("Before encryption: %s, len: %Ld\n", in_buffer, in_len);
    if ((err = ctr_encrypt(in_buffer , out_buffer, sizeof(in_buffer), &ctr)) != CRYPT_OK) {
        printf("ctr_encrypt error: %s\n", error_to_string(err));
        return -1;
    }
    out_len = strlen(out_buffer);
    printf("After encryption, length = %Ld\n", out_len);

    tmp_len = 1000;
    if ((err = base64_encode(out_buffer, out_len, tmp, &tmp_len)) != CRYPT_OK) {
        printf("ctr_encode error: %s\n", error_to_string(err));
        return -1;
    }
    printf("After encode: %s, len: %Ld\n", tmp, tmp_len);

    if ((err = base64_decode(tmp, tmp_len, in_buffer, &in_len)
        ) != CRYPT_OK) {
        printf("ctr_decode error: %s\n", error_to_string(err));
        return -1;
    }
    printf("After decode, length = %d\n", in_len);


    if ((err = ctr_setiv( IV, 16, &ctr)) != CRYPT_OK) {
        printf("ctr_setiv error: %s\n", error_to_string(err));
        return -1;
    }

    if ((err = ctr_decrypt(in_buffer, out_buffer, sizeof(in_buffer), &ctr)) != CRYPT_OK) {
        printf("ctr_decrypt error: %s\n", error_to_string(err));
        return -1;
    }

    out_len = strlen(out_buffer);
    printf("After decryption: %s, len: %Ld\n", out_buffer, out_len);

    if ((err = ctr_done(&ctr)) != CRYPT_OK) {
        printf("ctr_done error: %s\n", error_to_string(err));
        return -1;
    }

    zeromem(key, sizeof(key));
    zeromem(IV, sizeof(IV));
    zeromem(&ctr, sizeof(ctr));

    printf("#########################################################\n");
    return 0;
}

int main(int argc, char const *argv[])
{
    // test_blowfish_ecb("6afa31dba6598");
    // test_blowfish_ecb("6afa31dba6599");
    // test_rc4("6afa31dba6598");
    // test_rc4("6afa31dba6599");
    test_aes_ctr("6afa31dba6598");
    test_aes_ctr("6afa31dba6599");

    return 0;
}
