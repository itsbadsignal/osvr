#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static const char *greeting = "hello";   /* pointer: global; bytes: string literal */
static char last[16];                    /* global array, zero-initialised */

/* Return a heap copy of s in upper case. Caller frees. */
static char *dup_upper(const char *s)
{
    size_t n = strlen(s);
    char *out = malloc(n);
    if (out == NULL)
        return NULL;
    for (size_t i = 0; i <= n; i++) {
        char c = s[i];
        out[i] = (c >= 'a' && c <= 'z') ? (char)(c - 32) : c;
    }
    return out;
}

int main(int argc, char **argv)
{
    char word[32];
    const char *src = argc > 1 ? argv[1] : greeting;

    snprintf(word, sizeof word, "%s", src);
    char *u = dup_upper(word);
    if (u == NULL)
        return 1;
    snprintf(last, sizeof last, "%s", u);
    printf("%s -> %s\n", word, u);
    free(u);
    return 0;
}
