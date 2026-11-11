/* harness.c: the smallest program that hands cJSON an exact-size input.
 * Build and run by smoke.sh. You do not need to edit this file. */
#include <stdlib.h>
#include <string.h>
#include "cJSON.h"

int main(void)
{
    /* The 7 input bytes: { " 1 " : 1 ,   No NUL terminator, no newline. */
    static const char input[7] = { '{', '"', '1', '"', ':', '1', ',' };

    /* A heap block of exactly 7 bytes, so the heap block ends where the input ends. */
    char *buf = malloc(7);
    if (buf == NULL)
        return 2;
    memcpy(buf, input, 7);

    /* Parse exactly 7 bytes, then release everything we own. */
    cJSON *json = cJSON_ParseWithLength(buf, 7);
    cJSON_Delete(json);   /* cJSON_Delete(NULL) is a no-op */
    free(buf);
    return 0;
}
