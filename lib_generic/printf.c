#include <stdio.h>

/* s3c6410 */
#define UFSTAT0    (*((volatile unsigned long *)0x7F005018))
#define UTXH0      (*((volatile unsigned char *)0x7F005020))

void __put_char(char *p, int num) {
    while (*p && num--) {
        __putchar(*p);
        p++;
    }
}

int printf(const char *fmt, ...)
{
    char print_buf[256];

    va_list args;
    unsigned int i;

    va_start(args, fmt);
    i = vsnprintf(print_buf, sizeof(print_buf),fmt, args);
    va_end(args);

    __put_char(print_buf, i);

    return 0;
}
