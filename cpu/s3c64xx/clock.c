#include "s3c6410.h"

#define ARM_RATIO    0   /* ARMCLK = DOUTAPLL / (ARM_RATIO + 1) */
#define MPLL_RATIO   1   /* DOUTMPLL = MOUTMPLL / (MPLL_RATIO + 1) */
#define HCLK_RATIO   1   /* HCLK = HCLKX2 / (HCLK_RATIO + 1) */
#define HCLKX2_RATIO 1   /* HCLKX2 = HCLKX2IN / (HCLKX2_RATIO + 1) */
#define PCLK_RATIO   3   /* PCLK = HCLKX2 / (PCLK_RATIO + 1) */
#define SECUR_RATIO  1   /* CLKSECUR = HCLKX2 / (SECUR_RATIO + 1) */
#define MFC_RATIO    1   /* CLKMFC = CLKMFCIN / (MFC_RATIO + 1) */

#define SDIV         1   /* PLL S divide value */
#define PDIV         3   /* PLL P divide value */
#define MDIV       266   /* PLL M divide value */
#define ENABLE       1   /* PLL enable control (0: disable, 1: enable) */

#define EPLL0_SDIV   2   /* PLL S divide value */
#define EPLL0_PDIV   1   /* PLL P divide value */
#define EPLL0_MDIV  32   /* PLL M divide value */
#define EPLL0_ENABLE 1   /* PLL enable control (0: disable, 1: enable) */

#define CP15DISABLE  0   /* Disables write asses to some system control processor */
#define SYNCMUXSEL   1   /* SYS CLOCK SELECT IN CMU, 1: DOUTAPLL */
#define SYNCMODE     1   /* SYNCMODEREQ to ARM, 1: Synchronous mode */

#define APLL_CON_VAL  ((ENABLE << 31) | (MDIV << 16) | (PDIV << 8) | (SDIV))
#define MPLL_CON_VAL  ((ENABLE << 31) | (MDIV << 16) | (PDIV << 8) | (SDIV))
#define EPLL_CON0_VAL ((EPLL0_ENABLE << 31) | (EPLL0_MDIV << 16) | (EPLL0_PDIV << 8) | (EPLL0_SDIV))

void clock_init(void)
{
    APLL_LOCK = 0xffff;
    MPLL_LOCK = 0xffff;
    EPLL_LOCK = 0xffff;

    OTHERS   |= (CP15DISABLE) | (SYNCMUXSEL << 6) | (SYNCMODE << 7);
    CLK_DIV0  = (ARM_RATIO) | (MPLL_RATIO << 4) | (HCLK_RATIO << 8) | (HCLKX2_RATIO << 9) | (PCLK_RATIO << 12) | (SECUR_RATIO << 18) | (MFC_RATIO << 28);
    APLL_CON  = APLL_CON_VAL; /* 500MHz */
    MPLL_CON  = MPLL_CON_VAL; /* 500MHz */
    EPLL_CON0 = EPLL_CON0_VAL;
    EPLL_CON1 = 0;

    CLK_SRC = 0x07; // EPLL_SEL = 1, MPLL_SEL = 1, APLL_SEL = 1
}
