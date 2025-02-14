/*****************************************************************************/
/**
* @file asm_vectors.s
*
* This file contains the initial vector table for the Cortex R5 processor
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who     Date     Changes
* ----- ------- -------- ---------------------------------------------------
* 5.00  pkp	02/10/14 Initial version
* </pre>
*
* @note
*
* None.
*
******************************************************************************/
.org 0
.text

.globl ResetHandler
.globl __vector_table
.globl FreeRTOS_FIQInterrupt
.globl FreeRTOS_DataAbortHandler
.globl FreeRTOS_PrefetchAbortHandler
.globl vPortInstallFreeRTOSVectorTable

.extern FreeRTOS_IRQ_Handler
.extern FreeRTOS_SVC_Handler
/*.extern FreeRTOS_SWI_Handler*/
.extern AbortRarry

.section .freertos_vectors, "a"
__vector_table:
	LDR	pc,=ResetHandler
	LDR	pc,=FreeRTOS_Undefined
	LDR pc,=FreeRTOS_SVC_Handler
	/*LDR pc,=FreeRTOS_SWI_Handler*/
	LDR	pc,=FreeRTOS_PrefetchAbortHandler
	LDR	pc,=FreeRTOS_DataAbortHandler
	NOP	/* Placeholder for address exception vector*/
	LDR pc,=FreeRTOS_IRQ_Handler
	LDR	pc,=FreeRTOS_FIQHandler

.text

FreeRTOS_FIQHandler:			/* FIQ vector handler */
	STMDB	sp!,{r0-r3,r12,lr}	/* state save from compiled code */
#if __ARM_FP
	/* Save the floating point context, if any. */
	FMRX  R1,  FPSCR
	VPUSH {D0-D15}
	/*VPUSH	{D16-D31}*/
	PUSH	{R1}
#endif
FreeRTOS_FIQLoop:
	BL	FIQInterrupt			/* FIQ vector */
#if __ARM_FP
	/* Restore the floating point context, if any. */
	POP 	{R0}
	/*VPOP	{D16-D31}*/
	VPOP	{D0-D15}
	VMSR  FPSCR, R0
#endif
	LDMIA	sp!,{r0-r3,r12,lr}	/* state restore from compiled code */
	SUBS	pc, lr, #4			/* adjust return */

.weak AbortHandler
.type AbortHandler, %function
AbortHandler:
    b  AbortHandler
.size AbortHandler, . - AbortHandler


FreeRTOS_Undefined:				/* Undefined handler */
	PUSH {r0}
	LDR r0, =AbortRarry
	STMIA r0!,{r0-r14}
	POP {r1}
	LDR r0, =AbortRarry
	STR r1,[r0]
	MRS r1, CPSR
	MSR CPSR, #0x10
	MOV r0, sp
	MSR CPSR, r1
	MOV r1, #0x00
	b 	AbortHandler

FreeRTOS_DataAbortHandler:		 /* Data Abort handler */
	PUSH {r0}
	LDR r0, =AbortRarry
	STMIA r0!,{r0-r14}
	POP {r1}
	LDR r0, =AbortRarry
	STR r1,[r0]
	MRS r1, CPSR
	MSR CPSR, #0x10
	MOV r0, sp
	MSR CPSR, r1
	MOV r1, #0x01
	b	AbortHandler

FreeRTOS_PrefetchAbortHandler:	/* Prefetch Abort handler */
	PUSH {r0}
	LDR r0, =AbortRarry
	STMIA r0!,{r0-r14}
	POP {r1}
	LDR r0, =AbortRarry
	STR r1,[r0]
	MRS r1, CPSR
	MSR CPSR, #0x10
	MOV r0, sp
	MSR CPSR, r1
	MOV r1, #0x02
	b	AbortHandler

.end
