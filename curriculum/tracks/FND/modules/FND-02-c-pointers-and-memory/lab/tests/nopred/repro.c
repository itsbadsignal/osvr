/* Fixture for check.sh (a passing learner repro). Models the iperf pattern, libc only. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define KEYSIZE 256

/* allocates: block of KEYSIZE bytes (the FIXED build adds one) */
static unsigned char *decrypt(size_t *len)
{
#ifdef FIXED
    unsigned char *p = malloc(KEYSIZE + 1);
#else
    unsigned char *p = malloc(KEYSIZE);
#endif
    if (!p) return NULL;
    /* fills: the length ends up equal to KEYSIZE */
    memset(p, 'A', KEYSIZE);
    *len = KEYSIZE;
    return p;
}

int main(void)
{
    size_t len;
    unsigned char *pt = decrypt(&len);
    if (!pt) return 1;
    pt[len] = '\0';           /* terminates */
    printf("%zu\n", strlen((char *)pt));
    free(pt);
    return 0;
}
