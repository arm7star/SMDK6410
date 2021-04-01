/*
 *************************************************************************
 *
 * Startup Code (reset vector)
 *
 * do important init only if we don't start from memory!
 * setup Memory and board specific bits prior to relocation.
 * relocate armboot to ram
 * setup stack
 *
 *************************************************************************
 */

#define I_BIT           0x80
#define F_BIT           0x40
#define ARM_MODE_IRQ    0x12
#define ARM_MODE_SVC    0x13

        .section .head.text
        .global _start
_start:
        ldr pc, ResetAddr
        ldr pc, _undefined_instruction
        ldr pc, _software_interrupt
        ldr pc, _prefetch_abort
        ldr pc, _data_abort
        ldr pc, _not_used
        ldr pc, _irq
        ldr pc, _fiq

ResetAddr:
        .word reset
_undefined_instruction:
        .word undefined_instruction
_software_interrupt:
        .word software_interrupt
_prefetch_abort:
        .word prefetch_abort
_data_abort:
        .word data_abort
_not_used:
        .word not_used
_irq:
        .word irq
_fiq:
        .word fiq
_pad:
        .word 0x12345678 /* now 16*4=64 */

.global _end_vect
_end_vect:
        .balignl 16,0xdeadbeef

/*
 * These are defined in the board-specific linker script.
 */
.global _bss_start
_bss_start:
        .word __bss_start

.global _bss_end
_bss_end:
        .word __bss_end

reset:
        /*
         * Setup a stack for IRQ and SVC mode
         */
        msr cpsr_c, #(I_BIT | F_BIT | ARM_MODE_IRQ)   /* IRQ Mode */
        ldr sp, =__stack_irq_end__

        msr cpsr_c, #(I_BIT | F_BIT | ARM_MODE_SVC)   /* Supervisor Mode, IRQ/FIQ disabled */
        ldr sp, =__stack_svc_end__

        /* Clear bss Section */
clear_bss:
        ldr r0, _bss_start                  /* find start of bss segment        */
        ldr r1, _bss_end                    /* stop here                        */
        mov r2, #0x00000000                 /* clear                            */

clbss_l:
        str r2, [r0]                        /* clear loop...                    */
        add r0, r0, #4
        cmp r0, r1
        ble clbss_l

        bl  SMDK6410_Initialize

        /*
         * Jump to C entry
         */
        mov lr, pc
        ldr pc, =main
        b   .

        .ltorg

/*
 *************************************************************************
 *
 * Interrupt Code
 *
 *************************************************************************
 */

/*
 * IRQ stack frame.
 */
#define S_FRAME_SIZE    72

#define S_OLD_R0        68
#define S_PSR           64
#define S_PC            60
#define S_LR            56
#define S_SP            52

#define S_IP            48
#define S_FP            44
#define S_R10           40
#define S_R9            36
#define S_R8            32
#define S_R7            28
#define S_R6            24
#define S_R5            20
#define S_R4            16
#define S_R3            12
#define S_R2            8
#define S_R1            4
#define S_R0            0

/*
 * use bad_save_user_regs for abort/prefetch/undef/swi ...
 * use irq_save_user_regs / irq_restore_user_regs for IRQ/FIQ handling
 */
    .macro  bad_save_user_regs
        sub    sp, sp, #S_FRAME_SIZE
        stmia  sp, {r0 - r12}

        add    r0, sp, #S_FRAME_SIZE
        mov    r1, lr
        mov    r2, pc
        mrs    r3, spsr
        add    r5, sp, #S_SP
        stmia  r5, {r0 - r3}
        mov    r0, sp
    .endm


/*
 * Undefined Instruction interrupt
 */
        .align  5
undefined_instruction:
        bad_save_user_regs
        b   .

/*
 * Software interrupt
 */
        .align  5
software_interrupt:
        bad_save_user_regs
        b   .

/*
 * Pre fetch abort interrupt
 */
        .align  5
prefetch_abort:
        bad_save_user_regs
        b   .

/*
 * Data abort interrupt
 */
        .align  5
data_abort:
        bad_save_user_regs
        b   .

        .align  5
not_used:
        b   .

/*
 * IRQ interrupt
 */
        .align  5
irq:
        stmfd   sp!, {r1-r3}                                    // We will use r1-r3 as temporary registers

        mov    r1, sp                                           // sp -> r1
        add    sp, sp, #12                                      // Adjust IRQ stack pointer
        sub    r2, lr, #4                                       // Adjust pc for return address to task
        mrs    r3, spsr                                         // Copy spsr (task's cpsr)

        /*
         * save task's context onto old task's stack
         */
        msr    cpsr_cxsf, #(I_BIT | F_BIT | ARM_MODE_SVC)       // Change to SVC mode

        stmfd  sp!, {r2}                                        // Push task's pc
        stmfd  sp!, {r4-r12, lr}                                // Push task's lr, r12-r4

        ldmfd  r1!, {r4-r6}                                     // Load task's r1-r3 from IRQ stack
        stmfd  sp!, {r4-r6}                                     // Push task's r1-r3 to SVC stack
        stmfd  sp!, {r0}                                        // Push task's r0 to SVC stack
        stmfd  sp!, {r3}                                        // Push task's cpsr

        ldr    r0, =OSIntNestingCtr                             // OSIntNestingCtr++
        ldrb   r1, [r0]
        add    r1, r1, #1
        strb   r1, [r0]

        cmp    r1, #1                                           // if (OSIntNestingCtr ==1) {
        bne    1f
        ldr    r4, =OSTCBCurPtr                                 //     OSTCBCur->OSTCBCurPtr = sp;
        ldr    r5, [r4]
        str    sp, [r5]                                         // }

1:
        msr    cpsr_c, #(I_BIT | F_BIT | ARM_MODE_IRQ)          // Change to IRQ mode to use IRQ stack to handle interrupt
        bl     Timer23_Exception
        msr    cpsr_c, #(I_BIT | F_BIT | ARM_MODE_SVC)          // Change to SVC mode
        bl     OSIntExit                                        // Call OSIntExit

        ldmfd  sp!, {r4}                                        // Pop the task's cpsr
        msr    spsr_cxsf, r4
        ldmfd  sp!, {r0-r12, lr, pc}^                           // Pop new task's context

/*
 * FIQ interrupt
 */
        .align  5
fiq:
        stmfd  sp!, {r0-r3,r12,lr}
        nop
        ldmfd  sp!, {r0-r3,r12,lr}
        subs   pc,  lr,  #4

#if 0 // del

/*
 *************************************************************************
 *
 * IRQ/FIQ enable/disable
 *
 *************************************************************************
 */

#define I_BIT      0x80                 // Interrupt bit of CPSR and SPSR
#define F_BIT      0x40                 // Interrupt bit of CPSR and SPSR

/*
 * Enable IRQ interrupt
 */
        .align  5
.global irq_enable
irq_enable:
        mrs    r0, cpsr
        bic    r0, r0, #I_BIT
        msr    cpsr_c, r0
        mov    pc, lr

/*
 * Disable IRQ interrupt
 */
        .align  5
.global irq_disable
irq_disable:
        mrs    r0, cpsr
        orr    r0, r0, #I_BIT
        msr    cpsr_c, r0
        mov    pc, lr

/*
 * Disable FIQ interrupt
 */
        .align  5
fiq_disable:
        mrs    r0, spsr
        orr    r0, r0, #F_BIT
        msr    cpsr_c, r0
        mov    pc, lr

/*
 * Enable FIQ interrupt
 */
        .align  5
fiq_enable:
        mrs    r0, spsr
        bic    r0, r0, #F_BIT
        msr    cpsr_c, r0
        mov    pc, lr

#endif
