/* predict-check fixture: global array, one-past-the-end write. */
#include <stdio.h>

static char table[16];

int main(int argc, char **argv)
{
    int i = 16 + (argc > 5);
    table[i] = 'x';
    printf("%c\n", table[0]);
    return 0;
}
