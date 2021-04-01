/*
*********************************************************************************************************
*                                              EXAMPLE CODE
*
*                             (c) Copyright 2010; Micrium, Inc.; Weston, FL
*
*               All rights reserved.  Protected by international copyright laws.
*               Knowledge of the source code may NOT be used to develop a similar product.
*               Please help us continue to provide the Embedded community with the finest
*               software available.  Your honesty is greatly appreciated.
*********************************************************************************************************
*/

/*
*********************************************************************************************************
*
*                                            EXAMPLE CODE
*                                    Samsung SMDK2440 Development Kit
*
* Filename      : main.c
* Version       : V1.00
* Programmer(s) :
*********************************************************************************************************
*/

#include "os.h"

/*
*********************************************************************************************************
*                                            LOCAL VARIABLES
*
* Note(s) : None
*
*********************************************************************************************************
*/

#define  APP_CFG_TASK_START_PRIO                           2u

static  OS_TCB      App_TaskStartTCB;                           /* Application startup task TCB.                        */
static  CPU_STK     App_TaskStartStkPtr[1024];                  /* Application startup task stack.                      */


/*
*********************************************************************************************************
*                                          STARTUP TASK
*
* Description : This is an example of a startup task.  As mentioned in the book's text, you MUST
*               initialize the ticker only once multitasking has started.
*
* Arguments   : p_arg   is the argument passed to 'AppTaskStart()' by 'OSTaskCreate()'.
*
* Returns     : none
*
* Notes       : 1) The first line of code is used to prevent a compiler warning because 'p_arg' is not
*                  used.  The compiler should not generate any code for this statement.
*********************************************************************************************************
*/

static  void  App_TaskStart (void *p_arg)
{
    int i = 0;
    OS_ERR err;

    (void)p_arg;

    while (1) {
        printf("App_TaskStart: %d\r\n", i++);
        OSTimeDly(150, OS_OPT_TIME_DLY, &err);
    }
}


/*
*********************************************************************************************************
*                                                main()
*
* Description : This is the standard entry point for C code.  It is assumed that your code will call
*               main() once you have performed all necessary initialization.
*
* Argument(s) : none
*
* Return(s)   : none
*
* Caller(s)   : Startup Code.
*
* Note(s)     : none.
*********************************************************************************************************
*/

int  main (void)
{
    OS_ERR   os_err;

    OSInit(&os_err);                                            /* Init uC/OS-III.                                      */

    OSTaskCreate((OS_TCB      *)&App_TaskStartTCB,              /* Create the start task                                */
                 (CPU_CHAR    *)"Start",
                 (OS_TASK_PTR  )App_TaskStart,
                 (void        *)0,
                 (OS_PRIO      )APP_CFG_TASK_START_PRIO,
                 (CPU_STK     *)App_TaskStartStkPtr,
                 (CPU_STK_SIZE )256,
                 (CPU_STK_SIZE )1024,
                 (OS_MSG_QTY   )0u,
                 (OS_TICK      )0u,
                 (void        *)0,
                 (OS_OPT       )(OS_OPT_TASK_STK_CHK | OS_OPT_TASK_STK_CLR),
                 (OS_ERR      *)&os_err);

    OSStart(&os_err);                                           /* Start multitasking.                                    */

    (void)&os_err;

    return (0);
}
