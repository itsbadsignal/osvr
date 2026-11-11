/* FIXTURE (spoiler): reference harness for check.sh realbug. Drives decode_auth_setting with an undecryptable token. */
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <openssl/evp.h>
#include "iperf_auth.h"
int main(void) {
    EVP_PKEY *k = load_privkey_from_file("private.pem");
    if (!k) { puts("no key"); return 2; }
    unsigned char raw[256]; memset(raw, 'A', sizeof raw);   /* garbage ciphertext, keysize bytes */
    unsigned char b64[512]; int n = EVP_EncodeBlock(b64, raw, sizeof raw); b64[n] = 0;
    char *u = NULL, *p = NULL; time_t ts = 0;
    int rc = decode_auth_setting(0, (char *)b64, k, &u, &p, &ts, 0);
    printf("rc=%d\n", rc);
    return 0;
}
