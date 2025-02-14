/**
 * @file irq_cfg.c
 * @brief
 * @author liuyouyuan (Youyuan.Liu@bst.ai)
 * @version 1.0
 * @date 2021-04-27
 *
 * @copyright Copyright (c) 2021  www.bst.ai
 *
 * @par Modify log:
 * <table>
 * <tr><th>Date       <th>Version <th>Author  <th>Description
 * <tr><td>2021-04-27 <td>1.0     <td>yyliu     <td>content
 * </table>
 *
 *  -------------------------------------------------------------------------------------------------------------------
 *  FILE DESCRIPTION
 *  -------------------------------------------------------------------------------------------------------------------
 *              File: BswInit.c
 *       Description: Provides the implementation of the main function and unimplemented tasks
 *********************************************************************************************************************/
/**********************************************************************************************************************
 *  INCLUDES
 *********************************************************************************************************************/
#include "isr_cfg.h"
#include "debug.h"
/**********************************************************************************************************************
 *  ADDITIONAL USER INCLUDES
 *********************************************************************************************************************/
extern void BST_Uart_IsrHandle(void *param);
extern void FreeRTOS_Tick_Handler(void *param);
extern void msgbx_node_isr_handle(void *param);
#ifdef TOUCH_SCREEN_ENABLE
extern void soc_lsp1_gpiochip7_isr_handler(void *param);
#endif
// extern void display0_isr_handler( void* irq_num );
// extern void display1_isr_handler( void* irq_num );
// extern void display2_isr_handler( void* irq_num );
// extern void dptx_isr_handler( void* irq_num );
/**********************************************************************************************************************
 * DO NOT CHANGE THIS COMMENT!           </USERBLOCK>
 *********************************************************************************************************************/
#define ISR_DEFINE(__isrName, __isrCore, __isrGroup, __isrPrio, __isrFn, __description, __attr) [__isrName] = {\
        .isrFn = __isrFn,                 \
        .attr = __attr,                   \
        .isrId =  __isrName,              \
        .isrCoreId = __isrCore,           \
        .isrGroup = __isrGroup,           \
        .isrPrio = __isrPrio,             \
        .description =__description,      \
},

isr_cfg_t isr_cfg_data[NUMBER_OF_ISR_NUM] = {
    #include "isr.cfg"
};
#undef ISR_DEFINE


/**********************************************************************************************************************
 *  VERSION CHECK
 **********************************************************************************************************************/

/**********************************************************************************************************************
 *  FUNCTIONS
 **********************************************************************************************************************/

/**
 * @brief init irq func
 */
void Isr_Init(void)
{
    int i = 0;
    {
        for(i = 0; i < NUMBER_OF_ISR_NUM; i++)
        {
            if(isr_cfg_data[i].isrFn != NULL)
            {
                cpu_gic_config(&isr_cfg_data[i]);
                cpu_gicd_set_enable(isr_cfg_data[i].isrId);
            }
        }
    }
}

/**
 * @brief register isr info and callback
 *
 * @param pIsrInfo isr info data.
 */
void IsrCfgInfoRegister(isr_cfg_t *pIsrInfo)
{
    cpu_gicd_clear_enable(pIsrInfo->isrId);

    isr_cfg_data[pIsrInfo->isrId].isrId = pIsrInfo->isrId;
    isr_cfg_data[pIsrInfo->isrId].attr = pIsrInfo->attr;
    isr_cfg_data[pIsrInfo->isrId].isrFn = pIsrInfo->isrFn;
    isr_cfg_data[pIsrInfo->isrId].isrCoreId = pIsrInfo->isrCoreId;
    isr_cfg_data[pIsrInfo->isrId].isrGroup = pIsrInfo->isrGroup;
    isr_cfg_data[pIsrInfo->isrId].isrPrio = pIsrInfo->isrPrio;
    isr_cfg_data[pIsrInfo->isrId].description = pIsrInfo->description;

    cpu_gic_config(&isr_cfg_data[pIsrInfo->isrId]);
    cpu_gicd_set_enable(isr_cfg_data[pIsrInfo->isrId].isrId);
}

void vApplicationIRQHandler(uint32 ulICCIAR)
{
    uint32 ulInterruptID;

	/* Re-enable interrupts. */
    __asm ( "cpsie i" );

	/* The ID of the interrupt is obtained by bitwise anding the ICCIAR value
	with 0x3FF. */
	ulInterruptID = ulICCIAR & 0x3FFUL;
	if( ulInterruptID < NUMBER_OF_ISR_NUM)
	{
		/* Call the function installed in the array of installed handler
		functions. */
        if((isr_cfg_data[ulInterruptID].isrFn != NULL) && (isr_cfg_data[ulInterruptID].isrGroup == ISR_GROUP_IRQ))
        {
            isr_cfg_data[ulInterruptID].isrFn((void *)ulInterruptID);
        }
	}
}

void FIQInterrupt(void)
{
    uint32 ulInterruptID = cpu_gicc_get_iar();

    ulInterruptID = ulInterruptID & 0x3FF;
    if(ulInterruptID < NUMBER_OF_ISR_NUM)
    {
        if((isr_cfg_data[ulInterruptID].isrFn != NULL) && (isr_cfg_data[ulInterruptID].isrGroup == ISR_GROUP_FIQ))
        {
            isr_cfg_data[ulInterruptID].isrFn((void *)ulInterruptID);
        }
        cpu_gicc_set_eoir(ulInterruptID);
    }
}

void BST_Uart_IsrHandle(void *param)
{
    uint32 isr_id = (uint32) param;
    Uart_IsrTransmit(LSP0_UART0);
}
