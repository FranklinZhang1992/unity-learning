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

int test_aes(unsigned char *plaintext)
{

}

int main(int argc, char const *argv[])
{
    // test_blowfish_ecb("6afa31dba6598");
    // test_blowfish_ecb("6afa31dba6599");
    test_rc4("6afa31dba6598");
    test_rc4("6afa31dba6599");

    return 0;
}
