/* FIXTURE: compiles and runs but never reaches the bug; check.sh realbug must FAIL it. */
#include <stdio.h>
#include "iperf_auth.h"
int main(void) { puts("nothing"); return 0; }
