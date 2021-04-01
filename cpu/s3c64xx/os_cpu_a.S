/*
 *********************************************************************************************************
 *                                               uC/OS-II
 *                                         The Real-Time Kernel
 *
 *
 *                                (c) Copyright 2006, Micrium, Weston, FL
 *                                          All Rights Reserved
 *
 *                                              ARM 7 Port
 *
 * File      : OS_CPU_A.S
 * Version   : V2.86
 * By        : Jean J. Labrosse
 *
 * For       : ARMv4
 * Mode      : ARM
 * Toolchain : RealView Development Suite
 *             RealView Microcontroller Development Kit (MDK)
 *             ARM Developer Suite (ADS)
 *             Keil uVision
 *********************************************************************************************************
 */


/*
 *********************************************************************************************************
 *                                      External references
 *********************************************************************************************************
 */
            .extern  OSPrioCur
            .extern  OSPrioHighRdy
            .extern  OSTCBCurPtr
            .extern  OSTCBHighRdyPtr

/*
 *********************************************************************************************************
 *                                  Functions declared in this file
 *********************************************************************************************************
 */
            .global OS_CPU_SR_Save
            .global OS_CPU_SR_Restore
            .global OSStartHighRdy
            .global OSCtxSw
            .global OSIntCtxSw


/*
 *********************************************************************************************************
 *                                  CRITICAL SECTION METHOD 3 FUNCTIONS
 * Prototypes :     OS_CPU_SR  OS_CPU_SR_Save(void);
 *                  void       OS_CPU_SR_Restore(OS_CPU_SR cpu_sr);
 *********************************************************************************************************
 */
        .text

OS_CPU_SR_Save:
        MRS     R0, CPSR                                @ Set IRQ and FIQ bits in CPSR to disable all interrupts
        ORR     R1, R0, #0xC0
        MSR     CPSR_c, R1
        MRS     R1, CPSR                                @ Confirm that CPSR contains the proper interrupt disable flags
        AND     R1, R1, #0xC0
        CMP     R1, #0xC0
        BNE     OS_CPU_SR_Save                          @ Not properly disabled (try again)
        MOV     PC, LR                                  @ Disabled, return the original CPSR contents in R0


OS_CPU_SR_Restore:
        MSR     CPSR_c,R0
        MOV     PC, LR

/*
*********************************************************************************************************
                                        START MULTITASKING
                                    void OSStartHighRdy(void)
*********************************************************************************************************
*/

        .text

OSStartHighRdy:
        MSR     CPSR_cxsf,#0x13|0xc0      // Switch to SVC mode with IRQ&FIQ disable

        LDR     R0, =OSTCBCurPtr
        LDR     R0, [R0]
        LDR     SP, [R0]

        LDMFD   SP!, {R0}
        MSR     SPSR_cxsf, R0
        LDMFD   SP!, {R0-R12, LR, PC}^

/*
 *********************************************************************************************************
 *                          PERFORM A CONTEXT SWITCH (From task level) - OSCtxSw()
 *********************************************************************************************************
 */
        .text

OSCtxSw:
                                          // SAVE CURRENT TASK'S CONTEXT
        STMFD   SP!, {LR}                 //     Push return address
        STMFD   SP!, {R0-R12, LR}         //     Push registers
        MRS     R4,  CPSR                 //     Push current CPSR
        STMFD   SP!, {R4}

        LDR     R0, =OSTCBCurPtr
        LDR     R0, [R0]
        STR     SP, [R0]

        LDR     R0, =OSPrioHighRdy
        LDR     R1, =OSPrioCur
        LDRB    R0, [R0]
        STRB    R0, [R1]                  // OSPrioCur = OSPrioHighRdy

        LDR     R0, =OSTCBHighRdyPtr
        LDR     R1, =OSTCBCurPtr
        LDR     R0, [R0]
        STR     R0, [R1]                  // OSTCBHighRdyPtr = OSTCBCurPtr

        LDR     R0, =OSTCBHighRdyPtr
        LDR     R0, [R0]
        LDR     SP, [R0]                  // SP = OSTCBHighRdyPtr->task_stack

        LDMFD   SP!, {R0}                 // POP CPSR
        MSR     SPSR_cxsf, R0
        LDMFD   SP!, {R0-R12, LR, PC}^

/*
 *********************************************************************************************************
 *                      PERFORM A CONTEXT SWITCH (From interrupt level) - OSIntCtxSw()
 *********************************************************************************************************
 */
        .text

OSIntCtxSw:

        LDR             R0, =OSPrioHighRdy
        LDR             R1, =OSPrioCur
        LDRB            R0, [R0]
        STRB            R0, [R1]        // OSPrioCur = OSPrioHighRdy

        LDR             R0, =OSTCBHighRdyPtr
        LDR             R1, =OSTCBCurPtr
        LDR             R0, [R0]
        STR             R0, [R1]        // OSTCBCurPtr = OSTCBHighRdyPtr

        LDR             R0, =OSTCBHighRdyPtr
        LDR             R0, [R0]
        LDR             SP, [R0]        // SP = OSTCBHighRdyPtr->task_stack

        LDMFD   SP!, {R0}               // POP CPSR
        MSR     SPSR_cxsf, R0
        LDMFD   SP!, {R0-R12, LR, PC}^

/*
 *********************************************************************************************************
 *                                     END OF FILE
 *********************************************************************************************************
 */

