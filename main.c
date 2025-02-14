#include <stdio.h>
#include "FreeRTOS.h"
#include "task.h"
#include "timers.h"
#include "semphr.h"
#include "common.h"
#include "isr_cfg.h"
#include "Uart.h"
#include "CDD_I2c.h"

/* Prototypes for the standard FreeRTOS callback/hook functions implemented
within this file. */
void vApplicationMallocFailedHook( void );
void vApplicationStackOverflowHook( TaskHandle_t pxTask, char *pcTaskName );
void vApplicationTickHook( void );

void vApplicationMallocFailedHook( void )
{
	/* Called if a call to pvPortMalloc() fails because there is insufficient
	free memory available in the FreeRTOS heap.  pvPortMalloc() is called
	internally by FreeRTOS API functions that create tasks, queues, software
	timers, and semaphores.  The size of the FreeRTOS heap is set by the
	configTOTAL_HEAP_SIZE configuration constant in FreeRTOSConfig.h. */
	taskDISABLE_INTERRUPTS();
	for( ;; );
}


void vApplicationIdleHook( void )
{
//volatile size_t xFreeHeapSpace;

	/* This is just a trivial example of an idle hook.  It is called on each
	cycle of the idle task.  It must *NOT* attempt to block.  In this case the
	idle task just queries the amount of FreeRTOS heap that remains.  See the
	memory management section on the http://www.FreeRTOS.org web site for memory
	management options.  If there is a lot of heap memory free then the
	configTOTAL_HEAP_SIZE value in FreeRTOSConfig.h can be reduced to free up
	RAM. */
	Dlt_MainFunction();
	//xFreeHeapSpace = xPortGetFreeHeapSize();

	/* Remove compiler warning about xFreeHeapSpace being set but never used. */
	//( void ) xFreeHeapSpace;
}

void vApplicationStackOverflowHook( TaskHandle_t pxTask, char *pcTaskName )
{
	( void ) pcTaskName;
	( void ) pxTask;

	/* Run time stack overflow checking is performed if
	configCHECK_FOR_STACK_OVERFLOW is defined to 1 or 2.  This hook
	function is called if a stack overflow is detected. */
	taskDISABLE_INTERRUPTS();
	for( ;; );
}

void vApplicationTickHook( void )
{
	#if( mainSELECTED_APPLICATION == 1 )
	{
		/* Only the comprehensive demo actually uses the tick hook. */
		extern void vFullDemoTickHook( void );
		vFullDemoTickHook();
	}
	#endif
}

/* configUSE_STATIC_ALLOCATION is set to 1, so the application must provide an
implementation of vApplicationGetIdleTaskMemory() to provide the memory that is
used by the Idle task. */
void vApplicationGetIdleTaskMemory( StaticTask_t **ppxIdleTaskTCBBuffer, StackType_t **ppxIdleTaskStackBuffer, uint32_t *pulIdleTaskStackSize )
{
/* If the buffers to be provided to the Idle task are declared inside this
function then they must be declared static - otherwise they will be allocated on
the stack and so not exists after this function exits. */
static StaticTask_t xIdleTaskTCB;
static StackType_t uxIdleTaskStack[ configMINIMAL_STACK_SIZE ];

	/* Pass out a pointer to the StaticTask_t structure in which the Idle task's
	state will be stored. */
	*ppxIdleTaskTCBBuffer = &xIdleTaskTCB;

	/* Pass out the array that will be used as the Idle task's stack. */
	*ppxIdleTaskStackBuffer = uxIdleTaskStack;

	/* Pass out the size of the array pointed to by *ppxIdleTaskStackBuffer.
	Note that, as the array is necessarily of type StackType_t,
	configMINIMAL_STACK_SIZE is specified in words, not bytes. */
	*pulIdleTaskStackSize = configMINIMAL_STACK_SIZE;
}

/* configUSE_STATIC_ALLOCATION and configUSE_TIMERS are both set to 1, so the
application must provide an implementation of vApplicationGetTimerTaskMemory()
to provide the memory that is used by the Timer service task. */
void vApplicationGetTimerTaskMemory( StaticTask_t **ppxTimerTaskTCBBuffer, StackType_t **ppxTimerTaskStackBuffer, uint32_t *pulTimerTaskStackSize )
{
/* If the buffers to be provided to the Timer task are declared inside this
function then they must be declared static - otherwise they will be allocated on
the stack and so not exists after this function exits. */
static StaticTask_t xTimerTaskTCB;
static StackType_t uxTimerTaskStack[ configTIMER_TASK_STACK_DEPTH ];

	/* Pass out a pointer to the StaticTask_t structure in which the Timer
	task's state will be stored. */
	*ppxTimerTaskTCBBuffer = &xTimerTaskTCB;

	/* Pass out the array that will be used as the Timer task's stack. */
	*ppxTimerTaskStackBuffer = uxTimerTaskStack;

	/* Pass out the size of the array pointed to by *ppxTimerTaskStackBuffer.
	Note that, as the array is necessarily of type StackType_t,
	configMINIMAL_STACK_SIZE is specified in words, not bytes. */
	*pulTimerTaskStackSize = configTIMER_TASK_STACK_DEPTH;
}

void vMainAssertCalled( const char *pcFileName, uint32_t ulLineNumber )
{
	int* pp = 0xb7000008;
    *pp = 0x1234;

	taskENTER_CRITICAL();
	myprintf("%s %d", __FUNCTION__, __LINE__);
	for( ;; );
}

// #define UART_PRINT_BASE 0xc1745000
// #define UART_PRINT_BASE  UART3_BASE_ADDR

// #define BUAD_RATE_ZEBU 0
// #define BUAD_RATE_38400 1
// #define BUAD_RATE_115200 2

// #define TXD0READY   (1<<6)
// #define RXD0READY   (1)

// #define UART_PRINT_REG_DLL    (   UART_PRINT_BASE + 0x0   )
// #define UART_PRINT_REG_THR    (   UART_PRINT_BASE + 0x0   )
// #define UART_PRINT_REG_RBR    (   UART_PRINT_BASE + 0x0   )
// #define UART_PRINT_REG_DLH    (   UART_PRINT_BASE + 0x4   )
// #define UART_PRINT_REG_LCR    (   UART_PRINT_BASE + 0xC   )
// #define UART_PRINT_REG_MCR    (   UART_PRINT_BASE + 0x10  )
// #define UART_PRINT_REG_LSR    (   UART_PRINT_BASE + 0x14  )
// #define UART_PRINT_REG_DLF    (   UART_PRINT_BASE + 0xC0  )


#define REG32(addr) (* ((volatile u32 *)((unsigned long)addr)) )
#define REG8(addr)	(* ((volatile u8 *)((unsigned long)addr)) )

// void uart_print_init(unsigned int buad, unsigned int port)
// {
//     //safety uart0,1 pinmux
//     REG_WRITE32(0xC0034000 + 0xff0 , 0xabcd1234);

//     REG_BIT_CLEAR32(0xc0034000 + 0x14, 0x3fe00000);
//     REG_BIT_CLEAR32(0xc0034000 + 0x18, 0x7);
//     REG_BIT_SET32(0xc0034000 + 0x14, BIT22 | BIT25 );

// 	REG_WRITE32(UART_PRINT_REG_MCR, 0);//disable flow ctrl
// 	REG_WRITE32(UART_PRINT_REG_MCR, (REG_READ32(UART_PRINT_REG_MCR)|(0x1<<1)));//clear rts

// 	REG_WRITE32(UART_PRINT_REG_LCR, (REG_READ32(UART_PRINT_REG_LCR)|(0x1<<7))); //enable access DLL & DLH

//     if (buad == BUAD_RATE_ZEBU)
//     {
//         REG_WRITE32(UART_PRINT_REG_DLL, 1); //set baud rate
//     }
//     else if(buad == BUAD_RATE_115200)
//     {
//         REG_WRITE32(UART_PRINT_REG_DLL, 13); //set baud rate
//         REG_WRITE32(UART_PRINT_REG_DLH, 0x0); //set baud rate
//         REG_WRITE32(UART_PRINT_REG_DLF, 0x24); //fractional part
//     }else if(buad == BUAD_RATE_38400)
//     {//38400
//         REG_WRITE32(UART_PRINT_REG_DLL, 40); //set baud rate
//         REG_WRITE32(UART_PRINT_REG_DLH, 0); //set baud rate
//         REG_WRITE32(UART_PRINT_REG_DLF, 0x2c); //fractional part
//     }

// 	REG_WRITE32(UART_PRINT_REG_LCR, ( REG_READ32(UART_PRINT_REG_LCR)&(~(0x1<<7)) ) ); //clear DLAB bit

// 	REG_WRITE32(UART_PRINT_REG_LCR, REG_READ32(UART_PRINT_REG_LCR)|(0x3)); //set data length to 8 bit, 1 stop bit,no parity


// 	delaySoft(10);
// }

void isr_test_cmd(unsigned int para)
{
    myprintf( "%s, %d\r\n",__FUNCTION__, __LINE__);
    REG_WRITE32(0x30000000+0x300, 0xABCD1234);
	// // REG_WRITE32(0x30000000+0x1EC, ((246 << 10) | 218)); /*soc timer0 to isr 0*/
	REG_WRITE32(0x30000000+0x1EC, 218); /*soc timer0 to isr 0*/
    myprintf( "%s, %d\r\n",__FUNCTION__, __LINE__);
    REG_WRITE32(0x20011000+8, 0);
    // //start config
    REG_WRITE32(0x20011000, 0x5555);
    // //timer bit2=0,intr unmask
    myprintf( "%s, %d\r\n",__FUNCTION__, __LINE__);
    REG_WRITE32(0x20011000+8, 3);
    myprintf( "%s, %d\r\n",__FUNCTION__, __LINE__);
}

extern void main(void);
extern void enable_caches(void);

void _startup(void)
{
	/*isr*/
	REG_WRITE32(0x30000000+0x300, 0xABCD1234);
	//REG_WRITE32(0x30000000+0x1EC, 219); /*soc timer1 to isr 0*/
	REG_RMW32(0x30000000+0x1EC, ((1<<10U)-1U), 219);   /*soc timer1 to isr 0*/
#ifdef UART_DEBUG
	REG_WRITE32(0x69036000, 0xABCD1234);
	REG_WRITE32(0x69036000+0x234, 105); /*rt uart2 to isr 0*/
    Uart_Init(&Uart_Config);
#endif
    DebugAndShell_Init();
	Isr_Init();
#ifdef TOUCH_SCREEN_ENABLE
	I2c_Init(NULL);
#endif
	main();
}
