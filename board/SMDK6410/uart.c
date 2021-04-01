#include "s3c6410.h"

void uart0_init(void)
{
    GPACON &= ~0xff;
    GPACON |= 0x22;

    ULCON0 = 0x3;    /* ULCON0[1:0]: Word Length, 11 = 8-bit; ULCON0[2]: Number of Stop Bit, 0 = One stop bit per frame; ULCON0[5:3]: Parity Mode, 0xx = No parity */
    UCON0  = 0x0e45; /* UCON0[1:0]: Receive Mode, Interrupt request or polling mode; UCON0[3:2]: Transmit Mode, 01 = Interrupt request or polling mode; UCON0[11:10]: Clock Selection, 11 = EXT_UCLK1(CLKUART): DIV_VAL = (EXT_UCLK1 / (bps x 16)) – 1 */
    UFCON0 = 0x01;   /* FIFO ENABLE */

    /*
     * DIV_VAL = UBRDIV0(整数部分) + UDIVSLOT0(小数部分) / 16
     * DIV_VAL = (EXT_UCLK1 / (bps x 16)) – 1 = (96MHz / (115200 x 16)) – 1 = 51.083
     */
    UBRDIV0   = 0x33;
    UDIVSLOT0 = 0; /* <<S3C6410X_UM_Rev1.20_090213.pdf>> P1094, 31.6.11 UART BAUD RATE CONFIGURE REGISTER */
}

int __putchar(int c)
{
    while (UFSTAT0 & (1 << 14)); /* 如果TX FIFO满，等待 */
    UTXH0 = c;                   /* 写数据 */
    return 0;
}

char getchar(void)
{
    while ((UFSTAT0 & 0x7f) == 0); /* 如果RX FIFO空，等待 */
    return URXH0;                  /* 取数据 */
}

void putchar(char c)
{
    while (UFSTAT0 & (1<<14)); /* 如果TX FIFO满，等待 */
    UTXH0 = c;                 /* 写数据 */
}
