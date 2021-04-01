#ifndef _OS_CPU_H
#define _OS_CPU_H

#ifdef   OS_CPU_GLOBALS
#define  OS_CPU_EXT
#else
#define  OS_CPU_EXT  extern
#endif

OS_CPU_EXT  CPU_STK  *OS_CPU_ExceptStkBase;

#endif
