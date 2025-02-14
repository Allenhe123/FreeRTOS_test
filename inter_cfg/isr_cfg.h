/**
 * @file irq_cfg.h
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
 */
#ifndef ISR_CFG_H
#define ISR_CFG_H

#include "gic_basic_api.h"
#include "sys_base_reg.h"
#include "Std_Types.h"
#include "Compiler.h"
#include "assert_lib.h"





#define ISR_DEFINE(__isrName, __isrCore, __isrPrio, __isrFn, __para, __description, __attr) ISR_##__isrName,
enum
{
#include "isr.cfg"
    ISR_NUM_END,
};
#undef ISR_DEFINE

#define NUMBER_OF_ISR_NUM   (NUMBER_OF_INT_VECTORS)

extern void Isr_Init(void);
extern void IsrCfgInfoRegister(isr_cfg_t *pIsrInfo);
#endif
