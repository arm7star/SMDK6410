void mask_irq(unsigned int irq)
{
    VIC0INTDisable(irq);
}

void unmask_irq(unsigned int irq)
{
    VIC0INTEnable(irq);
}

void __attribute__ ((weak)) do_irq(void)
{

}

void __attribute__ ((weak)) do_fiq(void)
{

}
