/* predict-check fixture: the overflowing access happens inside memset (a sanitizer interceptor). */
#include <stdlib.h>
#include <string.h>

static void clear(char *p, size_t n)
{
    memset(p, 0, n);
}

int main(void)
{
    char *buf = malloc(16);
    if (buf == NULL)
        return 1;
    clear(buf, 17);
    free(buf);
    return 0;
}
