/*
 * Created 190223 lynnl
 *
 * Compile:
 *  gcc -Wall -Wextra -L. -lmandoc2html driver.c -o driver
 */

#include <stdio.h>
#include <stdlib.h>
#include "mandoc2html.c"

void usage(void)
{
    fprintf(stderr, "usage: file\n");
    exit(-1);
    __builtin_unreachable();
}

int main(int argc, char *argv[])
{
    if (argc != 2) usage();
    return mandoc2html(argv[1]);
}

