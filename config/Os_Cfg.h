/**********************************************************************************************************************
 *  COPYRIGHT
 *  -------------------------------------------------------------------------------------------------------------------
 *  \verbatim
 *  Copyright (c) 2021 by Black Sesame Technologies (Shanghai) Co., Ltd                            All rights reserved.
 *
 *                This software is copyright protected and proprietary to Black Sesame Technologies (Shanghai) Co., Ltd
 *                Black Sesame Technologies (Shanghai) Co., Ltd grants to you only those rights as set out in the license conditions.
 *                All other rights remain with Black Sesame Technologies (Shanghai) Co., Ltd.
 *  \endverbatim
 *  -------------------------------------------------------------------------------------------------------------------
 *  LICENSE
 *  -------------------------------------------------------------------------------------------------------------------
 *            Module: Can
 *           Program: BST_SLP1
 *          Customer: xxxxxxxx
 *       Expiry Date: Not restricted
 *  Ordered Derivat.: A1000
 *    License Scope : The usage is restricted to xxxxxxxx
 *
 *  -------------------------------------------------------------------------------------------------------------------
 *  FILE DESCRIPTION
 *  -------------------------------------------------------------------------------------------------------------------
 *              File: Os_cfg..h
 *   Generation Time: 2021-16-19 10:29:18
 *           Project: Version 1
 *          Delivery: xxxxxxxx
 *      Tool Version: DaVinci Configurator/EB
 *
 *
 *********************************************************************************************************************/
#ifndef OS_CFG_H
#define OS_CFG_H
#include "Platform_Types.h"
#include "Compiler.h"
#include "Std_Types.h"
#include "FreeRTOS.h"
#include "event_groups.h"
/**
 *  \brief Task Declaration.
 *  \ingroup primitives-task
 *
 *  Declares a task. It is equivalent of an externa declaration of a task
 *  function defined with the _TASK()_ macro.
 *
 *  This declaration is currently not mandatory because task
 *  identifiers are all declared within the code generated by RT-Druid.
 *
 *  Reference: OSEK OS - ISO 17356-3 - 13.3.2.1
 *
 *  \param [in] TaskToBeDeclared The task to be declared.
 *  \return void
 */
#define DeclareTask(TaskToBeDeclared) \
        extern FUNC(void, OS_CODE) Func##TaskToBeDeclared ( void )

/**
 *  \brief Task Definition.
 *  \ingroup primitives-task
 *
 *  This macro is used when defining the body of a task.
 *
 *  Reference: OSEK OS - ISO 17356-3 - 13.3.5
 *
 *  \param [in] TaskToBeDefined This is the task keyword used also in the OIL
 *              file.
 */
#define TASK(TaskToBeDefined) \
        FUNC(void, OS_CODE) Func##TaskToBeDefined ( void )

typedef enum{
    DispIPCAppTask_TID,
    Dc0pipe0AppTask_TID,
    Dc0pipe1AppTask_TID,
    Dc1pipe0AppTask_TID,
    Dc1pipe1AppTask_TID,
    Dc2pipe0AppTask_TID,
    EdpAppTask_TID,
    MemManageIPCAppTask_TID,
    SuspendStClientTask_TID,
    SuspendRtClientTask_TID,
    IpcServerTask_TID,
    TouchTask_TID,
    LmIpcAppServerTask_TID,
    LocalAppTestTask_TID,
#ifdef MEM_MONITOR_APP
    MemMonitorTask_TID,
#endif //MEM_MONITOR_APP
    TASK_TID_MAX_NUM
}eTaskTidNum;

typedef enum{
    TASK_RUN_10MS_TIMER = 0,
    Alarm_Temperature_Monitor,
    Alarm_HeartBeat_Monitor,
    TIMER_TID_MAX_NUM
}eTimerTidNUm;
/**
 * @brief task stack config
 *
 */
#define MemManageIpcTask_STACK_SIZE     (512)
#define SuspendStClientTask_STACK_SIZE  (256)
#define SuspendRtClientTask_STACK_SIZE  (256)
#define IpcServerTask_STACK_SIZE        (512)
#define TouchTask_STACK_SIZE            (512)
#define LmIpcAppServerTask_STACK_SIZE   (512)
#define LocalAppTestTask_STACK_SIZE     (512)
#ifdef MEM_MONITOR_APP
#define MemMonitorTask_STACK_SIZE       (512)
#endif //MEM_MONITOR_APP
/**
 * @brief task prio level config
 *
 */
#define IpcServerTask_PRIO_LEVEL                (5)
#define MemManageIpcTask_PRIO_LEVEL             (6)
#define SuspendStClientTask_PRIO_LEVEL          (5)
#define SuspendRtClientTask_PRIO_LEVEL          (5)
#define TouchTask_PRIO_LEVEL                    (5)
#define LmIpcAppServerTask_PRIO_LEVEL           (5)
#define LocalAppTestTask_PRIO_LEVEL             (5)
#ifdef MEM_MONITOR_APP
#define MemMonitorTask_PRIO_LEVEL               (5)
#endif //MEM_MONITOR_APP
/**
 * @brief Queue buffer size
 *
 */
#define IpcAppTask_QUEUE_SIZE           8
#define Dc0Pipe0EventAppTask_QUEUE_SIZE           8
#define Dc0Pipe1EventAppTask_QUEUE_SIZE           8
#define Dc1Pipe0EventAppTask_QUEUE_SIZE           8
#define Dc1Pipe1EventAppTask_QUEUE_SIZE           8
#define Dc2Pipe0EventAppTask_QUEUE_SIZE           8
#define EdpEventAppTask_QUEUE_SIZE                8
#define IpcServerTask_QUEUE_SIZE                  8
#define TouchTask_QUEUE_SIZE                      8
#define LocalAppTestTask_QUEUE_SIZE               8
/***************************************************************************
 *
 * EVENTs declaration
 *
 **************************************************************************/
#define EVENT_ALARM_TRIGED              (1<<0)
#define EVENT_COM_SPI_SEQ_END           (1<<1)
#define EVENT_COM_IPC_NOTIFY            (1<<2)
#define EVENT_SPI_RECV_DATA             (1<<3)
#define EVENT_UDS_NEED_START            (1<<4)
#define EVENT_REBOOT_SYS                (1<<5)
#define EVENT_REBOOT_A55                (1<<6)
#define EVENT_IPC_RECV_MSG              (1<<7)
#define EVENT_DISPLAY_DC0               (1<<8)
#define EVENT_DISPLAY_DC1               (1<<9)
#define EVENT_DISPLAY_DC2               (1<<10)
#define EVENT_DISPLAY_DC3               (1<<11)
#define EVENT_DISPLAY_DC4               (1<<12)
#define EVENT_DISPLAY_EDP               (1<<13)

#define EVENT_GROUP_NUM                 (1)
#define EVENT_GROUP_WDG_ID              (0)

#define EVENT_WDG_CAN_TASK              (1<<0)
#define EVENT_WDG_COM_TASK              (1<<1)
#define EVENT_WDG_MISC_TASK             (1<<2)
#define EVENT_WDG_PWR_TASK              (1<<3)
#define EVENT_WDG_BIT_ALL               (0xF)


#define EventMaskType       uint32

extern EventMaskType WaitEvent(EventMaskType Mask);
extern void SetEvent(uint32 TaskId, EventMaskType event, boolean isIsr);
extern Std_ReturnType StartTimer(eTimerTidNUm TimerId, uint32 xTicktoWait);
extern void CreatEventGroup(uint32 EventGroupIndex);
extern void SetEventGroupBits(uint32 EventGroupIndex, EventBits_t EvnetBits);
extern EventBits_t WaitEventGroupBits(uint32 EventGroupIndex, const EventBits_t uxBitsToWaitFor,
                                const BaseType_t xClearOnExit,
                                const BaseType_t xWaitForAllBits,
                                TickType_t xTicksToWait);



extern void vMainAssertCalled( const char *pcFileName, uint32_t ulLineNumber );
// #define configASSERT( x ) if( ( x ) == 0 ) { vMainAssertCalled( __FILE__, __LINE__ ); }

extern void vConfigureTickInterrupt( void );
//#define configSETUP_TICK_INTERRUPT() vConfigureTickInterrupt()

extern void vClearTickInterrupt( void );
//#define configCLEAR_TICK_INTERRUPT() vClearTickInterrupt()

#endif