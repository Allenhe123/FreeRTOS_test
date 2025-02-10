#include "common.h"
#include "FreeRTOS.h"
#include "task.h"
#include "Os_Cfg.h"
#include "queue.h"
#include "timers.h"

static TaskHandle_t TaskHandleTable[TASK_TID_MAX_NUM];
static QueueHandle_t TaskQueueHandleTable[TASK_TID_MAX_NUM];
static TimerHandle_t TaskTimeHandleTable[TIMER_TID_MAX_NUM];
static EventGroupHandle_t xCreatedEventGroup[EVENT_GROUP_NUM];

EventMaskType WaitEvent(EventMaskType Mask)
{
    TaskHandle_t TaskHandle = NULL;
    uint32 TaskIdCnt = 0;
    EventMaskType event = 0;
    BaseType_t RetVal = pdFAIL;

    TaskHandle = xTaskGetCurrentTaskHandle();
    if(TaskHandle != NULL)
    {
        for(TaskIdCnt = 0; TaskIdCnt < TASK_TID_MAX_NUM; TaskIdCnt++)
        {
            if(TaskHandleTable[TaskIdCnt] == TaskHandle)
            {
                break;
            }
        }
    }

    if(TaskIdCnt != TASK_TID_MAX_NUM)
    {
        RetVal = xQueueReceive(TaskQueueHandleTable[TaskIdCnt], (uint32 *)&event, portMAX_DELAY);

        if(RetVal == pdPASS)
        {

        }
        else
        {
            event = 0;
        }
    }

    return event;
}

void SetEvent(uint32 TaskId, EventMaskType event, boolean isIsr)
{
    BaseType_t xHigherPriorityTaskWoken;
    BaseType_t xYieldRequired;

    if(TaskQueueHandleTable[TaskId] != NULL)
    {
        if(isIsr == false)
        {
            xQueueSend(TaskQueueHandleTable[TaskId], (uint32 *)&event, 0);
        }
        else
        {
            xYieldRequired = xQueueSendFromISR(TaskQueueHandleTable[TaskId], (void *)&event, &xHigherPriorityTaskWoken);
            if(xHigherPriorityTaskWoken)
            {
                portYIELD_FROM_ISR(xYieldRequired);
            }
        }
    }
}
Std_ReturnType StartTimer(eTimerTidNUm TimerId, uint32 xTicktoWait)
{
    Std_ReturnType RetValue = E_NOT_OK;

    if(TaskTimeHandleTable[TimerId] != NULL)
    {
        xTimerStart(TaskTimeHandleTable[TimerId], xTicktoWait);
        RetValue = E_OK;
    }

    return(RetValue);
}

void TaskTimerCallback(void)
{
    uint32 TaskIdCnt = 0;
    uint32 QueueData = 0;

    for(TaskIdCnt = 0; TaskIdCnt < TASK_TID_MAX_NUM; TaskIdCnt++)
    {
        if(TaskQueueHandleTable[TaskIdCnt] != NULL)
        {
            QueueData = EVENT_ALARM_TRIGED;
            xQueueSend(TaskQueueHandleTable[TaskIdCnt], (uint32 *)&QueueData, 0);
        }
    }
}

void CreatEventGroup(uint32 EventGroupIndex)
{
    xCreatedEventGroup[EventGroupIndex] = xEventGroupCreate();
}

void SetEventGroupBits(uint32 EventGroupIndex, EventBits_t EvnetBits)
{
    if(xCreatedEventGroup[EventGroupIndex] != NULL)
    {
        xEventGroupSetBits(xCreatedEventGroup[EventGroupIndex], EvnetBits);
    }
}

EventBits_t WaitEventGroupBits(uint32 EventGroupIndex, const EventBits_t uxBitsToWaitFor,
                                const BaseType_t xClearOnExit,
                                const BaseType_t xWaitForAllBits,
                                TickType_t xTicksToWait)
{
    EventBits_t EvBits;

    EvBits = xEventGroupWaitBits(xCreatedEventGroup[EventGroupIndex],
                                    uxBitsToWaitFor,
                                    xClearOnExit,
                                    xWaitForAllBits,
                                    xTicksToWait);
    return(EvBits);
}

FUNC(void, OS_CODE)
  StartupTask(void)
{
    TaskHandle_t xHandle = NULL;

    taskENTER_CRITICAL();
   
    xCreatedEventGroup[EVENT_GROUP_WDG_ID] = xEventGroupCreate();
	
    portTASK_USES_FLOATING_POINT();
    	
    taskEXIT_CRITICAL();
    	
    vTaskStartScheduler();
}

void main(void)
{
    StartupTask();
    while (1); 
}
