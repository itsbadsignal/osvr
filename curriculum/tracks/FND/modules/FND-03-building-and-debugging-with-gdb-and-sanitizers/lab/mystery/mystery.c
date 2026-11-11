/* Source of the Drill 2 binaries (built by build-mystery.sh, then removed from the image). */
#include <limits.h>
#include <stdlib.h>

static int add(int a, int b)
{
    return a + b;
}

int main(int argc, char **argv)
{
    char *p = malloc(8);
    if (p == NULL)
        return 1;
    p[argc] = 1;                      /* in bounds for argc 0..7 */
    int v = add(INT_MAX - 2, argc);   /* no overflow for argc <= 2 */
    free(p);
    (void)argv;
    return v == 0;
}
