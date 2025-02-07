/*
 * FreeRTOS Kernel V11.1.0
 * Copyright (C) 2024 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * SPDX-License-Identifier: MIT
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
 * https://www.FreeRTOS.org
 * https://github.com/FreeRTOS
 *
 */

/* ----------------------------------------------------------------------------------- */

    .arm
    .syntax unified
    .section freertos_system_calls

#define FREERTOS_ASSEMBLY
    #include "FreeRTOSConfig.h"
    #include "portmacro_asm.h"
    #include "mpu_syscall_numbers.h"
#undef FREERTOS_ASSEMBLY

/* ----------------------- Start of Port Specific System Calls ----------------------- */

/*
 * void vPortYield( void );
 */
.align 4
.global vPortYield
.type vPortYield, %function
vPortYield:
    SVC     #portSVC_YIELD
    BX      LR

/* ----------------------------------------------------------------------------------- */

/*
 * void vPortSystemCallExit( void );
 */
.align 4
.global vPortSystemCallExit
.type vPortSystemCallExit, %function
vPortSystemCallExit:
    SVC     #portSVC_SYSTEM_CALL_EXIT
    BX      LR

/* ----------------------------------------------------------------------------------- */

/*
 * BaseType_t xPortIsPrivileged( void );
 *
 * According to the Procedure Call Standard for the ARM Architecture (AAPCS):
 * - Return value must be in R0.
 */
.align 4
.global xPortIsPrivileged
.type xPortIsPrivileged, %function
xPortIsPrivileged:
    MRS     R0, CPSR        /* R0 = CPSR. */
    AND     R0, R0, #0x1F   /* R0 = R0 & 0x1F. Extract mode bits.*/
    CMP     R0, #USER_MODE  /* If R0 == #USER_MODE. */
    MOVEQ   R0, #0x0        /* Then, set R0 to 0 to indicate that the processer is not privileged. */
    MOVNE   R0, #0x01       /* Otherwise, set R0 to 1 to indicate that the processer is privileged. */
    BX      LR

/* ----------------------------------------------------------------------------------- */

/*
 * UBaseType_t ulPortCountLeadingZeros( UBaseType_t ulBitmap );
 *
 * According to the Procedure Call Standard for the ARM Architecture (AAPCS):
 * - Parameter ulBitmap is passed in R0.
 * - Return value must be in R0.
 */
.align 4
.weak ulPortCountLeadingZeros
.type ulPortCountLeadingZeros, %function
ulPortCountLeadingZeros:
    CLZ     R0, R0
    BX      LR

/* ------------------- End of Port Specific System Calls ------------------- */

.macro INVOKE_SYSTEM_CALL systemCallNumber, systemCallImpl
    PUSH    {R0}
    MRS     R0, CPSR
    AND     R0, R0, #0x1F
    CMP     R0, #USER_MODE
    POP     {R0}
    SVCEQ   \systemCallNumber
    B       \systemCallImpl
.endm

/* ----------------------------------------------------------------------------------- */

.extern MPU_xTaskGetTickCountImpl
.align 4
.global MPU_xTaskGetTickCount
.type MPU_xTaskGetTickCount, function
MPU_xTaskGetTickCount:
    /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_xTaskGetTickCount, MPU_xTaskGetTickCountImpl*/
    ldr r12, = MPU_xTaskGetTickCountImpl
    bx r12

/* ----------------------------------------------------------------------------------- */

.extern MPU_uxTaskGetNumberOfTasksImpl
.align 4
.global MPU_uxTaskGetNumberOfTasks
.type MPU_uxTaskGetNumberOfTasks, function
MPU_uxTaskGetNumberOfTasks:
    /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_uxTaskGetNumberOfTasks, MPU_uxTaskGetNumberOfTasksImpl*/
    ldr r12, = MPU_uxTaskGetNumberOfTasksImpl
    bx r12

/* ----------------------------------------------------------------------------------- */

.extern MPU_vTaskSetTimeOutStateImpl
.align 4
.global MPU_vTaskSetTimeOutState
.type MPU_vTaskSetTimeOutState, function
MPU_vTaskSetTimeOutState:
    /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_vTaskSetTimeOutState, MPU_vTaskSetTimeOutStateImpl*/
    ldr r12, = MPU_vTaskSetTimeOutStateImpl
    bx r12

/* ----------------------------------------------------------------------------------- */

.extern MPU_xTaskCheckForTimeOutImpl
.align 4
.global MPU_xTaskCheckForTimeOut
.type MPU_xTaskCheckForTimeOut, function
MPU_xTaskCheckForTimeOut:
    /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_xTaskCheckForTimeOut, MPU_xTaskCheckForTimeOutImpl*/
    ldr r12, = MPU_xTaskCheckForTimeOutImpl
    bx r12

/* ----------------------------------------------------------------------------------- */

.extern MPU_xQueueGenericSendImpl
.align 4
.global MPU_xQueueGenericSend
.type MPU_xQueueGenericSend, function
MPU_xQueueGenericSend:
    /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_xQueueGenericSend, MPU_xQueueGenericSendImpl*/
    ldr r12, = MPU_xQueueGenericSendImpl
    bx r12

/* ----------------------------------------------------------------------------------- */

.extern MPU_uxQueueMessagesWaitingImpl
.align 4
.global MPU_uxQueueMessagesWaiting
.type MPU_uxQueueMessagesWaiting, function
MPU_uxQueueMessagesWaiting:
    /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_uxQueueMessagesWaiting, MPU_uxQueueMessagesWaitingImpl*/
    ldr r12, = MPU_uxQueueMessagesWaitingImpl
    bx r12

/* ----------------------------------------------------------------------------------- */

.extern MPU_uxQueueSpacesAvailableImpl
.align 4
.global MPU_uxQueueSpacesAvailable
.type MPU_uxQueueSpacesAvailable, function
MPU_uxQueueSpacesAvailable:
    /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_uxQueueSpacesAvailable, MPU_uxQueueSpacesAvailableImpl*/
    ldr r12, = MPU_uxQueueSpacesAvailableImpl
    bx r12

/* ----------------------------------------------------------------------------------- */

.extern MPU_xQueueReceiveImpl
.align 4
.global MPU_xQueueReceive
.type MPU_xQueueReceive, function
MPU_xQueueReceive:
    /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_xQueueReceive, MPU_xQueueReceiveImpl*/
    ldr r12, = MPU_xQueueReceiveImpl
    bx r12

/* ----------------------------------------------------------------------------------- */

.extern MPU_xQueuePeekImpl
.align 4
.global MPU_xQueuePeek
.type MPU_xQueuePeek, function
MPU_xQueuePeek:
    /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_xQueuePeek, MPU_xQueuePeekImpl*/
    ldr r12, = MPU_xQueuePeekImpl
    bx r12

/* ----------------------------------------------------------------------------------- */

.extern MPU_xQueueSemaphoreTakeImpl
.align 4
.global MPU_xQueueSemaphoreTake
.type MPU_xQueueSemaphoreTake, function
MPU_xQueueSemaphoreTake:
    /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_xQueueSemaphoreTake, MPU_xQueueSemaphoreTakeImpl*/
    ldr r12, = MPU_xQueueSemaphoreTakeImpl
    bx r12
/* ----------------------------------------------------------------------------------- */

#if ( configUSE_EVENT_GROUPS == 1 )

    .extern MPU_xEventGroupWaitBitsImpl
    .align 4
    .global MPU_xEventGroupWaitBitsEntry
    .type MPU_xEventGroupWaitBitsEntry, function
    MPU_xEventGroupWaitBitsEntry:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_xEventGroupWaitBits, MPU_xEventGroupWaitBitsImpl*/
        ldr r12, = MPU_xEventGroupWaitBitsImpl
        bx r12
    /* ----------------------------------------------------------------------------------- */

    .extern MPU_xEventGroupClearBitsImpl
    .align 4
    .global MPU_xEventGroupClearBits
    .type MPU_xEventGroupClearBits, function
    MPU_xEventGroupClearBits:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_xEventGroupClearBits, MPU_xEventGroupClearBitsImpl*/
        ldr r12, = MPU_xEventGroupClearBitsImpl
        bx r12
    /* ----------------------------------------------------------------------------------- */

    .extern MPU_xEventGroupSetBitsImpl
    .align 4
    .global MPU_xEventGroupSetBits
    .type MPU_xEventGroupSetBits, function
    MPU_xEventGroupSetBits:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_xEventGroupSetBits, MPU_xEventGroupSetBitsImpl*/
        ldr r12, = MPU_xEventGroupSetBitsImpl
        bx r12
    /* ----------------------------------------------------------------------------------- */

    .extern MPU_xEventGroupSyncImpl
    .align 4
    .global MPU_xEventGroupSync
    .type MPU_xEventGroupSync, function
    MPU_xEventGroupSync:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_xEventGroupSync, MPU_xEventGroupSyncImpl*/
        ldr r12, = MPU_xEventGroupSyncImpl
        bx r12

#endif /* if ( configUSE_EVENT_GROUPS == 1 ) */

/* ----------------------------------------------------------------------------------- */

#if ( configUSE_STREAM_BUFFERS == 1 )

    .extern MPU_xStreamBufferSendImpl
    .align 4
    .global MPU_xStreamBufferSend
    .type MPU_xStreamBufferSend, function
    MPU_xStreamBufferSend:
        INVOKE_SYSTEM_CALL #SYSTEM_CALL_xStreamBufferSend, MPU_xStreamBufferSendImpl

    /* ----------------------------------------------------------------------------------- */

    .extern MPU_xStreamBufferReceiveImpl
    .align 4
    .global MPU_xStreamBufferReceive
    .type MPU_xStreamBufferReceive, function
    MPU_xStreamBufferReceive:
        INVOKE_SYSTEM_CALL #SYSTEM_CALL_xStreamBufferReceive, MPU_xStreamBufferReceiveImpl

    /* ----------------------------------------------------------------------------------- */

    .extern MPU_xStreamBufferIsFullImpl
    .align 4
    .global MPU_xStreamBufferIsFull
    .type MPU_xStreamBufferIsFull, function
    MPU_xStreamBufferIsFull:
        INVOKE_SYSTEM_CALL #SYSTEM_CALL_xStreamBufferIsFull, MPU_xStreamBufferIsFullImpl

    /* ----------------------------------------------------------------------------------- */

    .extern MPU_xStreamBufferIsEmptyImpl
    .align 4
    .global MPU_xStreamBufferIsEmpty
    .type MPU_xStreamBufferIsEmpty, function
    MPU_xStreamBufferIsEmpty:
        INVOKE_SYSTEM_CALL #SYSTEM_CALL_xStreamBufferIsEmpty, MPU_xStreamBufferIsEmptyImpl

    /* ----------------------------------------------------------------------------------- */

    .extern MPU_xStreamBufferSpacesAvailableImpl
    .align 4
    .global MPU_xStreamBufferSpacesAvailable
    .type MPU_xStreamBufferSpacesAvailable, function
    MPU_xStreamBufferSpacesAvailable:
        INVOKE_SYSTEM_CALL #SYSTEM_CALL_xStreamBufferSpacesAvailable, MPU_xStreamBufferSpacesAvailableImpl

    /* ----------------------------------------------------------------------------------- */

    .extern MPU_xStreamBufferBytesAvailableImpl
    .align 4
    .global MPU_xStreamBufferBytesAvailable
    .type MPU_xStreamBufferBytesAvailable, function
    MPU_xStreamBufferBytesAvailable:
        INVOKE_SYSTEM_CALL #SYSTEM_CALL_xStreamBufferBytesAvailable, MPU_xStreamBufferBytesAvailableImpl

    /* ----------------------------------------------------------------------------------- */

    .extern MPU_xStreamBufferSetTriggerLevelImpl
    .align 4
    .global MPU_xStreamBufferSetTriggerLevel
    .type MPU_xStreamBufferSetTriggerLevel, function
    MPU_xStreamBufferSetTriggerLevel:
        INVOKE_SYSTEM_CALL #SYSTEM_CALL_xStreamBufferSetTriggerLevel, MPU_xStreamBufferSetTriggerLevelImpl

    /* ----------------------------------------------------------------------------------- */

    .extern MPU_xStreamBufferNextMessageLengthBytesImpl
    .align 4
    .global MPU_xStreamBufferNextMessageLengthBytes
    .type MPU_xStreamBufferNextMessageLengthBytes, function
    MPU_xStreamBufferNextMessageLengthBytes:
        INVOKE_SYSTEM_CALL #SYSTEM_CALL_xStreamBufferNextMessageLengthBytes, MPU_xStreamBufferNextMessageLengthBytesImpl

#endif /* if ( configUSE_STREAM_BUFFERS == 1 ) */

/* ----------------------------------------------------------------------------------- */

#if ( ( INCLUDE_xTaskDelayUntil == 1 ) || ( INCLUDE_vTaskDelayUntil == 1 ) )

    .extern MPU_xTaskDelayUntilImpl
    .align 4
    .global MPU_xTaskDelayUntil
    .type MPU_xTaskDelayUntil, function
    MPU_xTaskDelayUntil:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_xTaskDelayUntil, MPU_xTaskDelayUntilImpl*/
        ldr r12, = MPU_xTaskDelayUntilImpl
        bx r12


#endif /* if ( ( INCLUDE_xTaskDelayUntil == 1 ) || ( INCLUDE_vTaskDelayUntil == 1 ) ) */

/* ----------------------------------------------------------------------------------- */

#if ( INCLUDE_xTaskAbortDelay == 1 )

    .extern MPU_xTaskAbortDelayImpl
    .align 4
    .global MPU_xTaskAbortDelay
    .type MPU_xTaskAbortDelay, function
    MPU_xTaskAbortDelay:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_xTaskAbortDelay, MPU_xTaskAbortDelayImpl*/
        ldr r12, = MPU_xTaskAbortDelayImpl
        bx r12

#endif /* if ( INCLUDE_xTaskAbortDelay == 1 ) */

/* ------------------------------------------------------------------------------- */

#if ( INCLUDE_vTaskDelay == 1 )

    .extern MPU_vTaskDelayImpl
    .align 4
    .global MPU_vTaskDelay
    .type MPU_vTaskDelay, function
    MPU_vTaskDelay:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_vTaskDelay, MPU_vTaskDelayImpl*/
        ldr r12, = MPU_vTaskDelayImpl
        bx r12

#endif /* if ( INCLUDE_vTaskDelay == 1 ) */

/* ------------------------------------------------------------------------------- */

#if ( INCLUDE_uxTaskPriorityGet == 1 )

    .extern MPU_uxTaskPriorityGetImpl
    .align 4
    .global MPU_uxTaskPriorityGet
    .type MPU_uxTaskPriorityGet, function
    MPU_uxTaskPriorityGet:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_uxTaskPriorityGet, MPU_uxTaskPriorityGetImpl*/
        ldr r12, = MPU_uxTaskPriorityGetImpl
        bx r12

#endif /* if ( INCLUDE_uxTaskPriorityGet == 1 ) */

/* ------------------------------------------------------------------------------- */

#if ( INCLUDE_eTaskGetState == 1 )

    .extern MPU_eTaskGetStateImpl
    .align 4
    .global MPU_eTaskGetState
    .type MPU_eTaskGetState, function
    MPU_eTaskGetState:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_eTaskGetState, MPU_eTaskGetStateImpl*/
        ldr r12, = MPU_eTaskGetStateImpl
        bx r12

#endif /* if ( INCLUDE_eTaskGetState == 1 ) */

/* ------------------------------------------------------------------------------- */

#if ( configUSE_TRACE_FACILITY == 1 )

    .extern MPU_vTaskGetInfoImpl
    .align 4
    .global MPU_vTaskGetInfo
    .type MPU_vTaskGetInfo, function
    MPU_vTaskGetInfo:
        INVOKE_SYSTEM_CALL #SYSTEM_CALL_vTaskGetInfo, MPU_vTaskGetInfoImpl

    /* ------------------------------------------------------------------------------- */

    .extern MPU_uxTaskGetSystemStateImpl
    .align 4
    .global MPU_uxTaskGetSystemState
    .type MPU_uxTaskGetSystemState, function
    MPU_uxTaskGetSystemState:
        INVOKE_SYSTEM_CALL #SYSTEM_CALL_uxTaskGetSystemState, MPU_uxTaskGetSystemStateImpl

#endif /* if ( configUSE_TRACE_FACILITY == 1 ) */

/* ------------------------------------------------------------------------------- */

#if ( ( configUSE_EVENT_GROUPS == 1 ) && ( configUSE_TRACE_FACILITY == 1 ) )
    .extern MPU_uxEventGroupGetNumberImpl
    .align 4
    .global MPU_uxEventGroupGetNumber
    .type MPU_uxEventGroupGetNumber, function
    MPU_uxEventGroupGetNumber:
    INVOKE_SYSTEM_CALL #SYSTEM_CALL_uxEventGroupGetNumber, MPU_uxEventGroupGetNumberImpl

    /* ------------------------------------------------------------------------------- */



    .extern MPU_vEventGroupSetNumberImpl
    .align 4
    .global MPU_vEventGroupSetNumber
    .type MPU_vEventGroupSetNumber, function
    MPU_vEventGroupSetNumber:
        INVOKE_SYSTEM_CALL #SYSTEM_CALL_vEventGroupSetNumber, MPU_vEventGroupSetNumberImpl

    /* ------------------------------------------------------------------------------- */

#endif /* if ( ( configUSE_EVENT_GROUPS == 1 ) && ( configUSE_TRACE_FACILITY == 1 ) ) */

/* ------------------------------------------------------------------------------- */

#if ( INCLUDE_xTaskGetIdleTaskHandle == 1 )

    .extern MPU_xTaskGetIdleTaskHandleImpl
    .align 4
    .global MPU_xTaskGetIdleTaskHandle
    .type MPU_xTaskGetIdleTaskHandle, function
    MPU_xTaskGetIdleTaskHandle:
        INVOKE_SYSTEM_CALL #SYSTEM_CALL_xTaskGetIdleTaskHandle, MPU_xTaskGetIdleTaskHandleImpl


#endif /* if ( INCLUDE_xTaskGetIdleTaskHandle == 1 ) */

/* ------------------------------------------------------------------------------- */

#if ( INCLUDE_vTaskSuspend == 1 )

    .extern MPU_vTaskSuspendImpl
    .align 4
    .global MPU_vTaskSuspend
    .type MPU_vTaskSuspend, function
    MPU_vTaskSuspend:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_vTaskSuspend, MPU_vTaskSuspendImpl*/
        ldr r12, = MPU_vTaskSuspendImpl
        bx r12

    /* ------------------------------------------------------------------------------- */

    .extern MPU_vTaskResumeImpl
    .align 4
    .global MPU_vTaskResume
    .type MPU_vTaskResume, function
    MPU_vTaskResume:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_vTaskResume, MPU_vTaskResumeImpl*/
        ldr r12, = MPU_vTaskResumeImpl
        bx r12

    /* ------------------------------------------------------------------------------- */

#endif /* if ( INCLUDE_vTaskSuspend == 1 ) */

/* ------------------------------------------------------------------------------- */

#if ( configGENERATE_RUN_TIME_STATS == 1 )

    .extern MPU_ulTaskGetRunTimeCounterImpl
    .align 4
    .global MPU_ulTaskGetRunTimeCounter
    .type MPU_ulTaskGetRunTimeCounter, function
    MPU_ulTaskGetRunTimeCounter:
        INVOKE_SYSTEM_CALL #SYSTEM_CALL_ulTaskGetRunTimeCounter, MPU_ulTaskGetRunTimeCounterImpl

    /* ------------------------------------------------------------------------------- */

    .extern MPU_ulTaskGetRunTimePercentImpl
    .align 4
    .global MPU_ulTaskGetRunTimePercent
    .type MPU_ulTaskGetRunTimePercent, function
    MPU_ulTaskGetRunTimePercent:
        INVOKE_SYSTEM_CALL #SYSTEM_CALL_ulTaskGetRunTimePercent, MPU_ulTaskGetRunTimePercentImpl

    /* ------------------------------------------------------------------------------- */

    #if ( INCLUDE_xTaskGetIdleTaskHandle == 1 )

        .extern MPU_ulTaskGetIdleRunTimePercentImpl
        .align 4
        .global MPU_ulTaskGetIdleRunTimePercent
        .type MPU_ulTaskGetIdleRunTimePercent, function
        MPU_ulTaskGetIdleRunTimePercent:
            INVOKE_SYSTEM_CALL #SYSTEM_CALL_ulTaskGetIdleRunTimePercent, MPU_ulTaskGetIdleRunTimePercentImpl

        /* --------------------------------------------------------------------------- */

        .extern MPU_ulTaskGetIdleRunTimeCounterImpl
        .align 4
        .global MPU_ulTaskGetIdleRunTimeCounter
        .type MPU_ulTaskGetIdleRunTimeCounter, function
        MPU_ulTaskGetIdleRunTimeCounter:
            INVOKE_SYSTEM_CALL #SYSTEM_CALL_ulTaskGetIdleRunTimeCounter, MPU_ulTaskGetIdleRunTimeCounterImpl

        /* --------------------------------------------------------------------------- */

    #endif /* if ( INCLUDE_xTaskGetIdleTaskHandle == 1 ) */

#endif /* if ( configGENERATE_RUN_TIME_STATS == 1 )*/

/* --------------------------------------------------------------------------- */

#if ( configUSE_APPLICATION_TASK_TAG == 1 )

    .extern MPU_vTaskSetApplicationTaskTagImpl
    .align 4
    .global MPU_vTaskSetApplicationTaskTag
    .type MPU_vTaskSetApplicationTaskTag, function
    MPU_vTaskSetApplicationTaskTag:
        INVOKE_SYSTEM_CALL #SYSTEM_CALL_vTaskSetApplicationTaskTag, MPU_vTaskSetApplicationTaskTagImpl

    /* ------------------------------------------------------------------------------- */

    .extern MPU_xTaskGetApplicationTaskTagImpl
    .align 4
    .global MPU_xTaskGetApplicationTaskTag
    .type MPU_xTaskGetApplicationTaskTag, function
    MPU_xTaskGetApplicationTaskTag:
        INVOKE_SYSTEM_CALL #SYSTEM_CALL_xTaskGetApplicationTaskTag, MPU_xTaskGetApplicationTaskTagImpl

    /* ------------------------------------------------------------------------------- */

#endif /* if ( configUSE_APPLICATION_TASK_TAG == 1 ) */

/* ------------------------------------------------------------------------------- */

#if ( configNUM_THREAD_LOCAL_STORAGE_POINTERS != 0 )

    .extern MPU_vTaskSetThreadLocalStoragePointerImpl
    .align 4
    .global MPU_vTaskSetThreadLocalStoragePointer
    .type MPU_vTaskSetThreadLocalStoragePointer, function
    MPU_vTaskSetThreadLocalStoragePointer:
        INVOKE_SYSTEM_CALL #SYSTEM_CALL_vTaskSetThreadLocalStoragePointer, MPU_vTaskSetThreadLocalStoragePointerImpl

    /* ------------------------------------------------------------------------------- */

    .extern MPU_pvTaskGetThreadLocalStoragePointerImpl
    .align 4
    .global MPU_pvTaskGetThreadLocalStoragePointer
    .type MPU_pvTaskGetThreadLocalStoragePointer, function
    MPU_pvTaskGetThreadLocalStoragePointer:
        INVOKE_SYSTEM_CALL #SYSTEM_CALL_pvTaskGetThreadLocalStoragePointer, MPU_pvTaskGetThreadLocalStoragePointerImpl

    /* ------------------------------------------------------------------------------- */

#endif /* if ( configNUM_THREAD_LOCAL_STORAGE_POINTERS != 0 ) */

/* ------------------------------------------------------------------------------- */

#if ( INCLUDE_uxTaskGetStackHighWaterMark == 1 )

    .extern MPU_uxTaskGetStackHighWaterMarkImpl
    .align 4
    .global MPU_uxTaskGetStackHighWaterMark
    .type MPU_uxTaskGetStackHighWaterMark, function
    MPU_uxTaskGetStackHighWaterMark:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_uxTaskGetStackHighWaterMark, MPU_uxTaskGetStackHighWaterMarkImpl*/
        ldr r12, = MPU_uxTaskGetStackHighWaterMarkImpl
        bx r12

#endif /* if ( INCLUDE_uxTaskGetStackHighWaterMark == 1 ) */

/* ------------------------------------------------------------------------------- */

#if ( INCLUDE_uxTaskGetStackHighWaterMark2 == 1 )

    .extern MPU_uxTaskGetStackHighWaterMark2Impl
    .align 4
    .global MPU_uxTaskGetStackHighWaterMark2
    .type MPU_uxTaskGetStackHighWaterMark2, function
    MPU_uxTaskGetStackHighWaterMark2:
        INVOKE_SYSTEM_CALL #SYSTEM_CALL_uxTaskGetStackHighWaterMark2, MPU_uxTaskGetStackHighWaterMark2Impl

#endif /* if ( INCLUDE_uxTaskGetStackHighWaterMark2 == 1 ) */

/* ------------------------------------------------------------------------------- */

#if ( ( INCLUDE_xTaskGetCurrentTaskHandle == 1 ) || ( configUSE_MUTEXES == 1 ) )

    .extern MPU_xTaskGetCurrentTaskHandleImpl
    .align 4
    .global MPU_xTaskGetCurrentTaskHandle
    .type MPU_xTaskGetCurrentTaskHandle, function
    MPU_xTaskGetCurrentTaskHandle:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_xTaskGetCurrentTaskHandle, MPU_xTaskGetCurrentTaskHandleImpl*/
        ldr r12, = MPU_xTaskGetCurrentTaskHandleImpl
        bx r12

#endif /* if( INCLUDE_xTaskGetCurrentTaskHandle == 1 ) || ( configUSE_MUTEXES == 1 ) ) */

/* ------------------------------------------------------------------------------- */

#if ( INCLUDE_xTaskGetSchedulerState == 1 )

    .extern MPU_xTaskGetSchedulerStateImpl
    .align 4
    .global MPU_xTaskGetSchedulerState
    .type MPU_xTaskGetSchedulerState, function
    MPU_xTaskGetSchedulerState:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_xTaskGetSchedulerState, MPU_xTaskGetSchedulerStateImpl*/
        ldr r12, = MPU_xTaskGetSchedulerStateImpl
        bx r12


#endif /* if ( INCLUDE_xTaskGetSchedulerState == 1 ) */

/* ------------------------------------------------------------------------------- */

#if ( ( configUSE_MUTEXES == 1 ) && ( INCLUDE_xSemaphoreGetMutexHolder == 1 ) )

    .extern MPU_xQueueGetMutexHolderImpl
    .align 4
    .global MPU_xQueueGetMutexHolder
    .type MPU_xQueueGetMutexHolder, function
    MPU_xQueueGetMutexHolder:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_xQueueGetMutexHolder, MPU_xQueueGetMutexHolderImpl*/
        ldr r12, = MPU_xQueueGetMutexHolderImpl
        bx r12

#endif /* if ( ( configUSE_MUTEXES == 1 ) && ( INCLUDE_xSemaphoreGetMutexHolder == 1 ) ) */

/* ------------------------------------------------------------------------------- */

#if ( configUSE_RECURSIVE_MUTEXES == 1 )

    .extern MPU_xQueueTakeMutexRecursiveImpl
    .align 4
    .global MPU_xQueueTakeMutexRecursive
    .type MPU_xQueueTakeMutexRecursive, function
    MPU_xQueueTakeMutexRecursive:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_xQueueTakeMutexRecursive, MPU_xQueueTakeMutexRecursiveImpl*/
        ldr r12, = MPU_xQueueTakeMutexRecursiveImpl
        bx r12

    /* ------------------------------------------------------------------------------- */

    .extern MPU_xQueueGiveMutexRecursiveImpl
    .align 4
    .global MPU_xQueueGiveMutexRecursive
    .type MPU_xQueueGiveMutexRecursive, function
    MPU_xQueueGiveMutexRecursive:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_xQueueGiveMutexRecursive, MPU_xQueueGiveMutexRecursiveImpl*/
        ldr r12, = MPU_xQueueGiveMutexRecursiveImpl
        bx r12

    /* ------------------------------------------------------------------------------- */

#endif /* if ( configUSE_RECURSIVE_MUTEXES == 1 ) */

/* ------------------------------------------------------------------------------- */

#if ( configUSE_QUEUE_SETS == 1 )

    .extern MPU_xQueueSelectFromSetImpl
    .align 4
    .global MPU_xQueueSelectFromSet
    .type MPU_xQueueSelectFromSet, function
    MPU_xQueueSelectFromSet:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_xQueueSelectFromSet, MPU_xQueueSelectFromSetImpl*/
        ldr r12, = MPU_xQueueSelectFromSetImpl
        bx r12

    /* ------------------------------------------------------------------------------- */

    .extern MPU_xQueueAddToSetImpl
    .align 4
    .global MPU_xQueueAddToSet
    .type MPU_xQueueAddToSet, function
    MPU_xQueueAddToSet:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_xQueueAddToSet, MPU_xQueueAddToSetImpl*/
        ldr r12, = MPU_xQueueAddToSetImpl
        bx r12

    /* ------------------------------------------------------------------------------- */

#endif /* if ( configUSE_QUEUE_SETS == 1 ) */

/* ------------------------------------------------------------------------------- */

#if ( configQUEUE_REGISTRY_SIZE > 0 )

    .extern MPU_vQueueAddToRegistryImpl
    .align 4
    .global MPU_vQueueAddToRegistry
    .type MPU_vQueueAddToRegistry, function
    MPU_vQueueAddToRegistry:
       /* INVOKE_SYSTEM_CALL #SYSTEM_CALL_vQueueAddToRegistry, MPU_vQueueAddToRegistryImpl*/
       ldr r12, = MPU_vQueueAddToRegistryImpl
       bx r12

    /* ------------------------------------------------------------------------------- */

    .extern MPU_vQueueUnregisterQueueImpl
    .align 4
    .global MPU_vQueueUnregisterQueue
    .type MPU_vQueueUnregisterQueue, function
    MPU_vQueueUnregisterQueue:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_vQueueUnregisterQueue, MPU_vQueueUnregisterQueueImpl*/
        ldr r12, = MPU_vQueueUnregisterQueueImpl
        bx r12

    /* ------------------------------------------------------------------------------- */

    .extern MPU_pcQueueGetNameImpl
    .align 4
    .global MPU_pcQueueGetName
    .type MPU_pcQueueGetName, function
    MPU_pcQueueGetName:
       /* INVOKE_SYSTEM_CALL #SYSTEM_CALL_pcQueueGetName, MPU_pcQueueGetNameImpl*/
       ldr r12, = MPU_pcQueueGetNameImpl
       bx r12

    /* ------------------------------------------------------------------------------- */

#endif /* if ( configQUEUE_REGISTRY_SIZE > 0 ) */

/* ------------------------------------------------------------------------------- */

#if ( configUSE_TIMERS == 1 )

    .extern MPU_pvTimerGetTimerIDImpl
    .align 4
    .global MPU_pvTimerGetTimerID
    .type MPU_pvTimerGetTimerID, function
    MPU_pvTimerGetTimerID:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_pvTimerGetTimerID, MPU_pvTimerGetTimerIDImpl*/
        ldr r12, = MPU_pvTimerGetTimerIDImpl
        bx r12

    /* ------------------------------------------------------------------------------- */

    .extern MPU_vTimerSetTimerIDImpl
    .align 4
    .global MPU_vTimerSetTimerID
    .type MPU_vTimerSetTimerID, function
    MPU_vTimerSetTimerID:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_vTimerSetTimerID, MPU_vTimerSetTimerIDImpl*/
        ldr r12, = MPU_vTimerSetTimerIDImpl
        bx r12

    /* ------------------------------------------------------------------------------- */

    .extern MPU_xTimerIsTimerActiveImpl
    .align 4
    .global MPU_xTimerIsTimerActive
    .type MPU_xTimerIsTimerActive, function
    MPU_xTimerIsTimerActive:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_xTimerIsTimerActive, MPU_xTimerIsTimerActiveImpl*/
        ldr r12, = MPU_xTimerIsTimerActiveImpl
        bx r12

    /* ------------------------------------------------------------------------------- */

    .extern MPU_xTimerGetTimerDaemonTaskHandleImpl
    .align 4
    .global MPU_xTimerGetTimerDaemonTaskHandle
    .type MPU_xTimerGetTimerDaemonTaskHandle, function
    MPU_xTimerGetTimerDaemonTaskHandle:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_xTimerGetTimerDaemonTaskHandle, MPU_xTimerGetTimerDaemonTaskHandleImpl*/
        ldr r12, = MPU_xTimerGetTimerDaemonTaskHandleImpl
        bx r12

    /* ------------------------------------------------------------------------------- */

    .extern MPU_xTimerGenericCommandFromTaskImpl
    .align 4
    .global MPU_xTimerGenericCommandFromTaskEntry
    .type MPU_xTimerGenericCommandFromTaskEntry, function
    MPU_xTimerGenericCommandFromTaskEntry:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_xTimerGenericCommandFromTask, MPU_xTimerGenericCommandFromTaskImpl*/
        ldr r12, = MPU_xTimerGenericCommandFromTaskImpl
        bx r12

    /* ------------------------------------------------------------------------------- */

    .extern MPU_pcTimerGetNameImpl
    .align 4
    .global MPU_pcTimerGetName
    .type MPU_pcTimerGetName, function
    MPU_pcTimerGetName:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_pcTimerGetName, MPU_pcTimerGetNameImpl*/
        ldr r12, = MPU_pcTimerGetNameImpl
        bx r12

    /* ------------------------------------------------------------------------------- */

    .extern MPU_vTimerSetReloadModeImpl
    .align 4
    .global MPU_vTimerSetReloadMode
    .type MPU_vTimerSetReloadMode, function
    MPU_vTimerSetReloadMode:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_vTimerSetReloadMode, MPU_vTimerSetReloadModeImpl*/
        ldr r12, = MPU_vTimerSetReloadModeImpl
        bx r12

    /* ------------------------------------------------------------------------------- */

    .extern MPU_xTimerGetReloadModeImpl
    .align 4
    .global MPU_xTimerGetReloadMode
    .type MPU_xTimerGetReloadMode, function
    MPU_xTimerGetReloadMode:
       /* INVOKE_SYSTEM_CALL #SYSTEM_CALL_xTimerGetReloadMode, MPU_xTimerGetReloadModeImpl*/
       ldr r12, = MPU_xTimerGetReloadModeImpl
       bx r12

    /* ------------------------------------------------------------------------------- */

    .extern MPU_uxTimerGetReloadModeImpl
    .align 4
    .global MPU_uxTimerGetReloadMode
    .type MPU_uxTimerGetReloadMode, function
    MPU_uxTimerGetReloadMode:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_uxTimerGetReloadMode, MPU_uxTimerGetReloadModeImpl*/
        ldr r12, = MPU_uxTimerGetReloadModeImpl
        bx r12

    /* ------------------------------------------------------------------------------- */

    .extern MPU_xTimerGetPeriodImpl
    .align 4
    .global MPU_xTimerGetPeriod
    .type MPU_xTimerGetPeriod, function
    MPU_xTimerGetPeriod:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_xTimerGetPeriod, MPU_xTimerGetPeriodImpl*/
        ldr r12, = MPU_xTimerGetPeriodImpl
        bx r12

    /* ------------------------------------------------------------------------------- */

    .extern MPU_xTimerGetExpiryTimeImpl
    .align 4
    .global MPU_xTimerGetExpiryTime
    .type MPU_xTimerGetExpiryTime, function
    MPU_xTimerGetExpiryTime:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_xTimerGetExpiryTime, MPU_xTimerGetExpiryTimeImpl*/
        ldr r12, = MPU_xTimerGetExpiryTimeImpl
        bx r12

    /* ------------------------------------------------------------------------------- */

#endif /* if ( configUSE_TIMERS == 1 ) */

/* ------------------------------------------------------------------------------- */

#if ( configUSE_TASK_NOTIFICATIONS == 1 )

    .extern MPU_xTaskGenericNotifyImpl
    .align 4
    .global MPU_xTaskGenericNotifyEntry
    .type MPU_xTaskGenericNotifyEntry, function
    MPU_xTaskGenericNotifyEntry:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_xTaskGenericNotify, MPU_xTaskGenericNotifyImpl*/
        ldr r12, = MPU_xTaskGenericNotifyImpl
        bx r12

    /* ------------------------------------------------------------------------------- */

    .extern MPU_xTaskGenericNotifyWaitImpl
    .align 4
    .global MPU_xTaskGenericNotifyWaitEntry
    .type MPU_xTaskGenericNotifyWaitEntry, function
    MPU_xTaskGenericNotifyWaitEntry:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_xTaskGenericNotifyWait, MPU_xTaskGenericNotifyWaitImpl*/
        ldr r12, = MPU_xTaskGenericNotifyWaitImpl
        bx r12

    /* ------------------------------------------------------------------------------- */

    .extern MPU_ulTaskGenericNotifyTakeImpl
    .align 4
    .global MPU_ulTaskGenericNotifyTake
    .type MPU_ulTaskGenericNotifyTake, function
    MPU_ulTaskGenericNotifyTake:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_ulTaskGenericNotifyTake, MPU_ulTaskGenericNotifyTakeImpl*/
        ldr r12, = MPU_ulTaskGenericNotifyTakeImpl
        bx r12

    /* ------------------------------------------------------------------------------- */

    .extern MPU_xTaskGenericNotifyStateClearImpl
    .align 4
    .global MPU_xTaskGenericNotifyStateClear
    .type MPU_xTaskGenericNotifyStateClear, function
    MPU_xTaskGenericNotifyStateClear:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_xTaskGenericNotifyStateClear, MPU_xTaskGenericNotifyStateClearImpl*/
        ldr r12, = MPU_xTaskGenericNotifyStateClearImpl
        bx r12

    /* ------------------------------------------------------------------------------- */

    .extern MPU_ulTaskGenericNotifyValueClearImpl
    .align 4
    .global MPU_ulTaskGenericNotifyValueClear
    .type MPU_ulTaskGenericNotifyValueClear, function
    MPU_ulTaskGenericNotifyValueClear:
        /*INVOKE_SYSTEM_CALL #SYSTEM_CALL_ulTaskGenericNotifyValueClear, MPU_ulTaskGenericNotifyValueClearImpl*/
        ldr r12, = MPU_ulTaskGenericNotifyValueClearImpl
        bx r12

    /* ------------------------------------------------------------------------------- */

#endif /* if ( configUSE_TASK_NOTIFICATIONS == 1 ) */

/* ------------------------------------------------------------------------------- */

.end
