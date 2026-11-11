#include <stdio.h>

int total_runs = 0;                 /* global, initialised      */

static int sum(const int *v, int n) /* v is a pointer, not an array */
{
    int s = 0;
    for (int i = 0; i < n; i++)
        s += v[i];
    return s;
}

int main(void)
{
    int scores[4];
    int bonus = 7;

    for (int i = 0; i <= 4; i++)    /* runs for i = 0, 1, 2, 3, 4 */
        scores[i] = 10 * i;

    total_runs++;
    printf("sum=%d bonus=%d runs=%d\n", sum(scores, 4), bonus, total_runs);
    return 0;
}
