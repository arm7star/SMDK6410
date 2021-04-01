/*
 * timer.c
 */

#include "s3c6410.h"

void __attribute__((interrupt("irq"))) Isr_Timer0(void)
{
    static int i = 0;
    TINT_CSTAT |= (1 << 5); // 清除中断标志
    // printf("Isr_Timer0: %d\r\n", i++);
    i++;
    GPMDAT = ~(1 << (i % 4));

    // VIC0ADDRESS = 0; // 中断结束
    VIC0INTClear();
}

void s3c6410_timer_init(void)
{
    /* <<S3C6410X_UM_Rev1.20_090213.pdf>> P1100, Figure 32-1. PWMTIMER Clock Tree Diagram */
    TCFG0 &= (~0xff);     // 清除设置
    TCFG0 |= 265;         // 定时器0预分频265 + 1,由PCLK = 266MHz提供时钟, 266分频产生1MHz的定时器时钟
    TCFG1  = 0x0;         // Divider MUXx
    TCON &= (~0xff);      // 清除设置
    TCON |= 1 << 3;       // 定时器0自动更新使能
    TCNTB0 = 80000;       // 重装值
    TINT_CSTAT |= 1 << 5; // 清除中断标志
    TINT_CSTAT |= 1;      // 使能定时器0中断

    // 以下操作启动定时器0
    TCON |= 1 << 1;       // 手动更新
    TCON &= ~(1 << 1);    // 结束手动更新
    TCON |= 1;            // 启动定时器0
}

void Timer23_Exception()
{
    TINT_CSTAT |= (1 << 5); // 清除中断标志
    VIC0INTClear();

    OSTimeTick();

#if OS_TMR_EN > 0
    // signal timer task
    OSTmrSignal();
#endif
}

