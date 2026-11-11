/* FIXTURE: reaches a different ASan report (not the 390 write); check.sh realbug must FAIL it. */
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <openssl/evp.h>
#include "iperf_auth.h"
int main(void) {
    EVP_PKEY *k = load_privkey_from_file("private.pem");
    if (!k) return 2;
    char *u = NULL, *p = NULL; time_t ts = 0;
    int rc = decode_auth_setting(0, "", k, &u, &p, &ts, 0);
    printf("rc=%d\n", rc);
    return 0;
}
