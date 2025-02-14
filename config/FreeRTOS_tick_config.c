/*
 * FreeRTOS V202012.00
 * Copyright (C) 2020 Amazon.com, Inc. or its affiliates.  All Rights Reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * http://www.FreeRTOS.org
 * http://aws.amazon.com/freertos
 *
 * 1 tab == 4 spaces!
 */

/* FreeRTOS includes. */
#include "FreeRTOS.h"
#include "task.h"
#include "sys_base_reg.h"
#include "Platform_Types.h"
#include "gic_basic_api.h"
#include "isr_cfg.h"

#include "Os_Cfg.h"

#define LSP_CLOCK (100 * 1000000)
#define OSEE_TICK_RATE_HZ 1000
#define SYS_TICK_TIEMR_CFG SOC_INTR_SOC_TO_SOC_R5_INTR_0

volatile uint32 systemTick = 0;

/*
 * The application must provide a function that configures a peripheral to
 * create the FreeRTOS tick interrupt, then define configSETUP_TICK_INTERRUPT()
 * in FreeRTOSConfig.h to call the function.  This file contains a function
 * that is suitable for use on the Zynq SoC.
 */
void vConfigureTickInterrupt( void )
{
    uint32 period_tick = LSP_CLOCK/OSEE_TICK_RATE_HZ;
    switch(SYS_TICK_TIEMR_CFG)
    {
        case SOC_INTR_SOC_TO_SOC_R5_INTR_0:
            cpu_gicd_set_enable(SOC_INTR_SOC_TO_SOC_R5_INTR_0);
            REG_WRITE32(TIMER0_PWM0_BASE_ADDR+8, 0);
            //start config
            REG_WRITE32(TIMER0_PWM0_BASE_ADDR, period_tick);
            //timer bit2=0,intr unmask
            REG_WRITE32(TIMER0_PWM0_BASE_ADDR+8, 3);
            break;
        default:
        break;
    }
    cpu_gicd_set_enable(SOC_INTR_SOC_TO_SOC_R5_INTR_0);
    cpu_gic_config_nonsecure();

    int* pp = 0xb7000030;
    *pp = 0x5555;
}
/*-----------------------------------------------------------*/

void vClearTickInterrupt( void )
{
    unsigned int regVal;

    systemTick++;
    regVal = REG_READ32(TIMER0_PWM0_BASE_ADDR + 0xc);
    if(regVal != 0)
    {
        REG_READ32(TIMER0_PWM0_BASE_ADDR + 0xc);
    }

    int* pp = 0xb7000034;
    *pp = 0x5555;
}


