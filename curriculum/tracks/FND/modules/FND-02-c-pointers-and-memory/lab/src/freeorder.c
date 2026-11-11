/* freeorder.c: FND-02 variation 2. Off-by-one NUL write on the first byte past a heap block's usable size,
 * then free all the p blocks, then all the q blocks. Build WITHOUT sanitizers: the point is what glibc does.
 *   gcc -g -O0 freeorder.c -o freeorder && ./freeorder KEYSIZE [PAIRS]      (PAIRS defaults to 10, at most 64)
 */
#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>

int main(int argc, char **argv)
{
    size_t keysize = argc > 1 ? (size_t)strtoul(argv[1], NULL, 10) : 24;
    int pairs = argc > 2 ? atoi(argv[2]) : 10;
    char *p[64], *q[64];

    if (pairs < 1 || pairs > 64 || keysize == 0)
        return 2;
    for (int i = 0; i < pairs; i++) {
        p[i] = malloc(keysize);
        q[i] = malloc(keysize);
        if (p[i] == NULL || q[i] == NULL)
            return 1;
    }
    fprintf(stderr, "keysize %zu, usable %zu, %d pairs\n", keysize, malloc_usable_size(p[0]), pairs);
    for (int i = 0; i < pairs; i++)
        p[i][keysize] = '\0';           /* one byte past the requested size */
    for (int i = 0; i < pairs; i++)
        free(p[i]);
    for (int i = 0; i < pairs; i++)
        free(q[i]);
    fprintf(stderr, "all freed, no abort\n");
    return 0;
}
