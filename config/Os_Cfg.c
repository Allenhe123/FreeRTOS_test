
/******************************************************************************
**                                                                            **
** Copyright (C) Black Sesame Technologies (2023)                             **
**                                                                            **
** All rights reserved.                                                       **
**                                                                            **
** This document contains proprietary information belonging to Black Sesame   **
** Technologies. Passing on and copying of this document, and communication   **
** of its contents is not permitted without prior written authorization.      **
**                                                                            **
********************************************************************************
**                                                                            **
**  FILENAME  : Os_Cfg.c                                                      **
**                                                                            **
**  VERSION   : 8.0.0                                                         **
**                                                                            **
**  DATE, TIME: 2021-08-13, 10:33:30                                          **
**                                                                            **
**  GENERATOR : Build b210315-0853                                            **
**                                                                            **
**                                                                            **
**  VARIANT   : Variant PB                                                    **
**                                                                            **
**  PLATFORM  : Black Sesame TS_T46D0M10I0R0                                  **
**                                                                            **
**  AUTHOR    : DL-AUTOSAR-Engineering                                        **
**                                                                            **
**  VENDOR    : Black Sesame Technologies                                     **
**                                                                            **
**  DESCRIPTION  : os config file                                             **
**                                                                            **
**                                                                            **
**  MAY BE CHANGED BY USER : no                                               **
**                                                                            **
*******************************************************************************/
#include "Os_Cfg.h"
#include "common.h"

uint32 AbortRarry[15];
void AbortHandler(uint32 *pStack, uint32 type)
{
    uint8 *AbortType[3] ={
        "UndefinedAbort",
        "DataAbort",
        "PrefetchAbort"
    };

    myprintf("\r\n%s:\r\n\
    r0=0x%08x,\r\n\
    r1=0x%08x,\r\n\
    r2=0x%08x,\r\n\
    r3=0x%08x,\r\n\
    r4=0x%08x,\r\n\
    r5=0x%08x,\r\n\
    r6=0x%08x,\r\n\
    r7=0x%08x,\r\n\
    r8=0x%08x,\r\n\
    r9=0x%08x,\r\n\
    r10=0x%08x,\r\n\
    r11=0x%08x,\r\n\
    r12=0x%08x,\r\n\
    sp=0x%08x,\r\n\
    lr=0x%08x,\r\n",AbortType[type], AbortRarry[0], AbortRarry[1], AbortRarry[2], AbortRarry[3], AbortRarry[4], AbortRarry[5], AbortRarry[6], 
    AbortRarry[7], AbortRarry[8], AbortRarry[9], AbortRarry[10], AbortRarry[11], AbortRarry[12], AbortRarry[13], AbortRarry[14]);

    myprintf("\r\nUsrSP[0x%08x] Data:\r\n\
    0x%08x,0x%08x,0x%08x,0x%08x,\r\n\
    0x%08x,0x%08x,0x%08x,0x%08x,\r\n\
    0x%08x,0x%08x,0x%08x,0x%08x,\r\n\
    0x%08x,0x%08x,0x%08x,0x%08x\r\n", pStack[0], pStack[1], pStack[2], pStack[3], pStack[4], pStack[5], pStack[6], pStack[7]
    , pStack[8], pStack[9], pStack[10], pStack[11], pStack[12], pStack[13], pStack[14], pStack[15]);
    while (1)
    {
        ;
    }
}
