#include "s3c6410.h"

extern void __attribute__((interrupt("irq"))) Isr_Timer0(void);

static void disable_watch_dog(void)
{
    WTCON = 0;
}

static void SMDK6410_cpu_init(void)
{
    disable_watch_dog();
    clock_init();
}

static void SMDK6410_SDRAM_init(void)
{
    sdram_init();
}

static void SMDK6410_gpio_init(void)
{
    GPMCON = 0x11111;
    GPMPUD = 0x00;
    GPMDAT = 0x1F;
}

static void SMDK6410_uart_init(void)
{
    uart0_init();
}

void SMDK6410_timer_init(void)
{
    s3c6410_timer_init(); // initialize timer0
    VIC0INTEnable(INT_TIMER0); // VIC0INTENABLE |= (1 << INT_TIMER0);
}

void SMDK6410_Initialize(void)
{
    SMDK6410_cpu_init();
    SMDK6410_SDRAM_init();

    SMDK6410_mmu_init();

    SMDK6410_gpio_init();
    SMDK6410_uart_init();
    SMDK6410_timer_init();
}
