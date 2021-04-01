#ifndef __CPU_H
#define __CPU_H

// data type
typedef unsigned char  CPU_INT08U;
typedef unsigned short CPU_INT16U;
typedef unsigned int   CPU_INT32U;
typedef unsigned int   CPU_TS;
typedef char           CPU_CHAR;
typedef unsigned int   CPU_STK;
typedef unsigned int   CPU_STK_SIZE;
typedef unsigned int   CPU_DATA;
typedef unsigned int   CPU_TS_TMR;
typedef unsigned char  CPU_BOOLEAN;
typedef unsigned int   CPU_ADDR;
typedef unsigned int   CPU_SR;

// macro definition
#define LIB_VERSION      13500u
#define CPU_CORE_VERSION 12801u
#define DEF_INT_CPU_NBR_BITS (32)

#define DEF_FALSE (0u)
#define DEF_TRUE (1u)

#define DEF_ENABLED  (1u)
#define DEF_DISABLED (0u)

#define DEF_ON (1u)

#define DEF_BIT_NONE (0x00u)
#define DEF_BIT_01   (0x02u)
#define DEF_BIT_02   (0x04u)
#define DEF_BIT_03   (0x08u)
#define DEF_BIT_04   (0x10u)

#define DEF_OCTET_NBR_BITS  (8u)

#define DEF_INT_08U_MAX_VAL (0xFF)
#define DEF_INT_16U_MAX_VAL (0xFFFF)
#define DEF_INT_32U_MAX_VAL (0xFFFFFFFF)

#define DEF_YES  (1u)
#define DEF_NO   (0u)

#define CPU_TYPE_CREATE(char_1, char_2, char_3, char_4)   (((CPU_INT32U)((CPU_INT08U)(char_1)) << (0u * DEF_OCTET_NBR_BITS)) | \
                                                            ((CPU_INT32U)((CPU_INT08U)(char_2)) << (1u * DEF_OCTET_NBR_BITS)) | \
                                                            ((CPU_INT32U)((CPU_INT08U)(char_3)) << (2u * DEF_OCTET_NBR_BITS)) | \
                                                            ((CPU_INT32U)((CPU_INT08U)(char_4)) << (3u * DEF_OCTET_NBR_BITS)))

#define DEF_INT_CPU_U_MAX_VAL           DEF_INT_32U_MAX_VAL
#define DEF_BIT(bit)                     (1uL << (bit))

#define DEF_BIT_FIELD(bit_field, bit_shift)          ((((bit_field) >= DEF_INT_CPU_NBR_BITS) ? (DEF_INT_CPU_U_MAX_VAL)     \
                                                                       : (DEF_BIT(bit_field) - 1uL)) \
                                                                               << (bit_shift))

#define DEF_BIT_IS_SET(val, mask)              ((((mask) != 0u) && (((val) & (mask)) == (mask))) ? (DEF_YES) : (DEF_NO ))
#define DEF_BIT_IS_SET_ANY(val, mask)          ((((val) & (mask)) ==  0u)  ? (DEF_NO ) : (DEF_YES))
#define CPU_CFG_STK_GROWTH  CPU_STK_GROWTH_HI_TO_LO


// context definition
#define CPU_SR_ALLOC()       CPU_SR cpu_sr = 0;
#define CPU_INT_DIS()        {cpu_sr = OS_CPU_SR_Save();}
#define CPU_INT_EN()         {OS_CPU_SR_Restore(cpu_sr);}
#define CPU_CRITICAL_ENTER() CPU_INT_DIS()
#define CPU_CRITICAL_EXIT()  CPU_INT_EN()

#define OS_TS_GET()          (0)
#define OS_TASK_SW()         OSCtxSw()

#endif


