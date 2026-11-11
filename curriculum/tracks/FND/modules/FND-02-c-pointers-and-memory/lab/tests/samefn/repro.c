#include <stdlib.h>
int main(void)
{
    unsigned char *p = malloc(16);
    p[16] = 0;
#ifdef FIXED
#endif
    free(p);
    return 0;
}
