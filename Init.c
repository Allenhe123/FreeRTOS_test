
 *  -------------------------------------------------------------------------------------------------------------------
 *  FILE DESCRIPTION
 *  -------------------------------------------------------------------------------------------------------------------
 *              File: Init.c
 *       Description: Provides the implementation of the main function and unimplemented tasks
 *********************************************************************************************************************/
/**********************************************************************************************************************
 *  INCLUDES
 *********************************************************************************************************************/
#include "common.h"
#include "bst_ver_info.h"
#include "FreeRTOS.h"
#include "task.h"
#include "Os_Cfg.h"
#include "queue.h"
#include "timers.h"
#include "ipc_trans_runtime.h"
#include "power_str.h"
/**********************************************************************************************************************
 *  ADDITIONAL USER INCLUDES
 *********************************************************************************************************************/

/**********************************************************************************************************************
 * DO NOT CHANGE THIS COMMENT!           </USERBLOCK>
 *********************************************************************************************************************/
ADD_VER_INFO("xxxx", "xxx-1200",1,0,0,2024build)

/***************************************************************************
 *
 * Declare tasks
 *
 **************************************************************************/
DeclareTask(CanAppTask);
DeclareTask(ComAppTask);
DeclareTask(LinAppTask);
DeclareTask(IpcAppTask);
DeclareTask(IpcSerAppTask);
DeclareTask(IpcCliAppTask);
DeclareTask(DispIpcTask);
DeclareTask(Dc2Pipe0EventAppTask);
DeclareTask(Dc0Pipe0EventAppTask);
DeclareTask(Dc0Pipe1EventAppTask);
DeclareTask(Dc1Pipe0EventAppTask);
DeclareTask(Dc1Pipe1EventAppTask);
DeclareTask(EdpEventAppTask);
DeclareTask(MemManageTask);
DeclareTask(SuspendRtClientTask);
DeclareTask(SuspendStClientTask);
DeclareTask(TouchTask);
#ifdef TOUCH_SCREEN_ENABLE
DeclareTask(IpcServerTask);
#endif
DeclareTask(LocalAppTestTask);
DeclareTask(LmIpcAppServerTask);
#ifdef MEM_MONITOR_APP
DeclareTask(MemMonitorTask);
#endif //MEM_MONITOR_APP
/**********************************************************************************************************************
 *  VERSION CHECK
 **********************************************************************************************************************/

/**********************************************************************************************************************
 *  FUNCTIONS
 **********************************************************************************************************************/
TaskHandle_t IpcSerTaskHandle;
TaskHandle_t IpcCliTaskHandle;
TaskHandle_t DispIpcTaskHandle;
static TaskHandle_t TaskHandleTable[TASK_TID_MAX_NUM];
static QueueHandle_t TaskQueueHandleTable[TASK_TID_MAX_NUM];
static TimerHandle_t TaskTimeHandleTable[TIMER_TID_MAX_NUM];
static EventGroupHandle_t xCreatedEventGroup[EVENT_GROUP_NUM];

static StaticTask_t MemManageIpcTask_TcbBuffer;
static StackType_t MemManageIpcTask_StkBuffer[MemManageIpcTask_STACK_SIZE];
static StaticTask_t SuspendStClientTask_TcbBuffer;
static StackType_t SuspendStClientTask_StkBuffer[SuspendStClientTask_STACK_SIZE];
static StaticTask_t SuspendRtClientTask_TcbBuffer;
static StackType_t SuspendRtClientTask_StkBuffer[SuspendRtClientTask_STACK_SIZE];
static StaticTask_t IpcServerTask_TcbBuffer;
static StackType_t  IpcServerTask_StkBuffer[IpcServerTask_STACK_SIZE];
#ifdef MEM_MONITOR_APP
static StaticTask_t MemMonitorTask_TcbBuffer;
static StackType_t MemMonitorTask_StkBuffer[MemMonitorTask_STACK_SIZE];
#endif //MEM_MONITOR_APP
#ifdef TOUCH_MANAGER_ENABLE
static StaticTask_t LmIpcAppServerTask_TcbBuffer;
static StackType_t LmIpcAppServerTask_StkBuffer[LmIpcAppServerTask_STACK_SIZE];
static StaticTask_t LocalAppTestTask_TcbBuffer;
static StackType_t LocalAppTestTask_StkBuffer[LocalAppTestTask_STACK_SIZE];
#endif

static StaticTask_t TouchTask_TcbBuffer;
static StackType_t  TouchTask_StkBuffer[TouchTask_STACK_SIZE];

StaticQueue_t xQueueIpcAppTaskBuf;
static u32 xQueueIpcAppTaskStroage[IpcAppTask_QUEUE_SIZE];
StaticQueue_t xQueueDc0Pipe0EventAppTaskBuf;
static u32 xQueueDc0Pipe0EventAppTaskStroage[Dc0Pipe0EventAppTask_QUEUE_SIZE];
StaticQueue_t xQueueDc0Pipe1EventAppTaskBuf;
static u32 xQueueDc0Pipe1EventAppTaskStroage[Dc0Pipe1EventAppTask_QUEUE_SIZE];
StaticQueue_t xQueueDc1Pipe0EventAppTaskBuf;
static u32 xQueueDc1Pipe0EventAppTaskStroage[Dc1Pipe0EventAppTask_QUEUE_SIZE];
StaticQueue_t xQueueDc1Pipe1EventAppTaskBuf;
static u32 xQueueDc1Pipe1EventAppTaskStroage[Dc1Pipe1EventAppTask_QUEUE_SIZE];
StaticQueue_t xQueueDc2Pipe0EventAppTaskBuf;
static u32 xQueueDc2Pipe0EventAppTaskStroage[Dc2Pipe0EventAppTask_QUEUE_SIZE];
StaticQueue_t xQueueEdpEventAppTaskBuf;
static u32 xQueueEdpEventAppTaskStroage[EdpEventAppTask_QUEUE_SIZE];
StaticQueue_t xQueueIpcServerTaskBuf;
static u32 xQueueIpcServerTaskStroage[IpcServerTask_QUEUE_SIZE];
StaticQueue_t xQueueTouchTaskBuf;
static u32 xQueueTouchTaskStroage[TouchTask_QUEUE_SIZE];
StaticQueue_t xQueueLocalAppTestTaskBuf;
static u32 xQueueLocalAppTestTaskStroage[LocalAppTestTask_QUEUE_SIZE];


void TaskStackOverflowCheck(void)
{
    int i;
    TaskHandle_t task_handler;
    for (i = 0; i < TASK_TID_MAX_NUM; i++) {
        task_handler = TaskHandleTable[i];
        if (task_handler) {
            myprintf("[%d] %s: FreeStackDepth:%d\n", i,
                pcTaskGetName(task_handler),
                uxTaskGetStackHighWaterMark(task_handler));
        }
    }
}

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



/* Declare the stack that will be used by the task. The stack alignment must
   match its size and be a power of 2, so if 128 words are reserved for the stack
   then it must be aligned to ( 128 * 4 ) bytes. This example used GCC syntax. */
static StackType_t xTaskStack[ 256 ] __attribute__((aligned(256*4)));

/* Declare an array that will be accessed by the task. The task should only
   be able to read from the array, and not write to it. */
char cReadOnlyArray[ 32 ] __attribute__((aligned(32)));


StaticTask_t pxTaskBuffer;

void vTaskFunction(void* p) {
    int* pp = 0xb700001c;
    int a = 0x1111;
    *pp = a;
    for (;;)
    {
        *pp = a++;
        vTaskDelay(pdMS_TO_TICKS(1000));
    }
}

/* Fill in a TaskParameters_t structure to define the task - this is the
   structure passed to the xTaskCreateRestricted() function. */
static const TaskParameters_t xTaskDefinition =
{
    vTaskFunction, /* pvTaskCode */
    "A task", /* pcName */
    256, /* usStackDepth - defined in words, not bytes. */
    NULL, /* pvParameters */
    1, /* uxPriority - priority 1, start in User mode. */
    xTaskStack, /* puxStackBuffer - the array to use as the task stack. */

    /* xRegions - In this case only one of the three user definable regions is
       actually used. The parameters are used to set the region to read only. */
    {
        /* Base address Length Parameters */
        { cReadOnlyArray, 32, tskMPU_REGION_READ_ONLY },
        { 0, 0, 0 },
        { 0, 0, 0 },
    },
    &pxTaskBuffer
};

FUNC(void, OS_CODE)
  StartupTask(void)
{
    TaskHandle_t xHandle = NULL;

    //LOG(DBG_INFO,"BSWInt", "%s\r\n%s\r\n%s", s_bst_man_name,s_bst_pro_name,s_bst_ver_string);
 //   LOG(DBG_INFO,"BSWInt", "%s", s_bst_ver_info);
	int* p = 0xB7000000;
	*p = 0x6688;
 //   taskENTER_CRITICAL();

    //TaskTimeHandleTable[Alarm_Temperature_Monitor] = xTimerCreate("TemperTimer", pdMS_TO_TICKS(2000), pdTRUE, 0, Alarm_Report_Temperature_Handle);
    //TaskTimeHandleTable[Alarm_HeartBeat_Monitor] = xTimerCreate("HeartBeatTImer", pdMS_TO_TICKS(500), pdTRUE, 0, HeartBeatTimeOutHandle);
   
    BaseType_t ret = xTaskCreateRestricted( &xTaskDefinition, NULL );
    if (ret != pdPASS) {
        int* pp = 0xb7000004;
        *pp = 0x7798;
    } else {
        int* pp = 0xb7000004;
        *pp = 0x7797;
    }
   
    *p = 0x6699;

    xCreatedEventGroup[EVENT_GROUP_WDG_ID] = xEventGroupCreate();
    	
	
//    ipc_trans_layer_start(0, 0);
    	
	*p = 0x7788;
 //   portTASK_USES_FLOATING_POINT();
    	
	*p = 0x8888;
 //   taskEXIT_CRITICAL();
    	
	*p = 0x9999;
    vTaskStartScheduler();
    *p = 0x1111;

}

void main(void)
{
    // str
   init_str_framework("soc_r5");

    StartupTask();
    while (1); 
}
