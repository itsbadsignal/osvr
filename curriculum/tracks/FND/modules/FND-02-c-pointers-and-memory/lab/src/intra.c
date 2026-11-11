#include <stdio.h>
struct rec { char buf[8]; int id; };
int main(int argc, char **argv) {
    struct rec r = { "", 42 };
    int i = 8 + (argc > 5);     /* 8: one past buf, still inside r */
    r.buf[i] = 'X';
    printf("id=%d\n", r.id);
    return 0;
}
