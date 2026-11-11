#include <limits.h>
int main(int argc, char **argv){ int x = INT_MAX; (void)argv; x += argc; return x == 12345; }
