#include <s3c6410.h>

// 12.6.12 VECTOR ADDRESS REGISGERS, VICVECTADDR[0-31]
volatile unsigned long *VIC0VECTADDR = (unsigned long *)0x71200100;
volatile unsigned long *VIC1VECTADDR = (unsigned long *)0x71300100;

void VICEnable(void)
{
    asm volatile (
        "mrc p15, 0, r0, c1, c0, 0\n\t"
        "orr r0, r0, #(1<<24)\n\t"
        "mcr p15, 0, r0, c1, c0, 0\n\t"
        ::: "r0"
    );
}

void SetVIC0IsrAddr(int irq, unsigned long isr)
{
    VIC0VECTADDR[irq] = isr;
}

void VIC0INTEnable(int irq)
{
    VIC0INTENABLE |= (1 << irq);
}

void VIC0INTDisable(int irq)
{
    VIC0INTENABLE &= ~(1 << irq);
}

void VIC0INTClear(void)
{
    VIC0ADDRESS = 0; // 中断结束
}

void SetVIC1IsrAddr(int irq, unsigned long isr)
{
    VIC1VECTADDR[irq] = isr;
}

void VIC1INTEnable(int irq)
{
    VIC1INTENABLE |= (1 << irq);
}

void VIC1INTDisable(int irq)
{
    VIC1INTENABLE &= ~(1 << irq);
}

void VIC1INTClear(void)
{
    VIC1ADDRESS = 0; // 中断结束
}
