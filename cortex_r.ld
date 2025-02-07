_STACK_SIZE = 2*0x400;
_HEAP_SIZE = 2*0x400;

_SYSTEM_STACK_SIZE = 2 * 1024;
_ABORT_STACK_SIZE = 512;
_SUPERVISOR_STACK_SIZE = 2 * 1024;
_IRQ_STACK_SIZE = 2 * 512;
_FIQ_STACK_SIZE = 2 * 512;
_UNDEF_STACK_SIZE = 512;

_STACK_SIZE = DEFINED(_STACK_SIZE) ? _STACK_SIZE : 0x2000;
_HEAP_SIZE = DEFINED(_HEAP_SIZE) ? _HEAP_SIZE : 0x2000;

_ABORT_STACK_SIZE = DEFINED(_ABORT_STACK_SIZE) ? _ABORT_STACK_SIZE : 1024;
_SUPERVISOR_STACK_SIZE = DEFINED(_SUPERVISOR_STACK_SIZE) ? _SUPERVISOR_STACK_SIZE : 1024;
_IRQ_STACK_SIZE = DEFINED(_IRQ_STACK_SIZE) ? _IRQ_STACK_SIZE : 1024;
_FIQ_STACK_SIZE = DEFINED(_FIQ_STACK_SIZE) ? _FIQ_STACK_SIZE : 1024;
_UNDEF_STACK_SIZE = DEFINED(_UNDEF_STACK_SIZE) ? _UNDEF_STACK_SIZE : 1024;

MEMORY
{
  /*flash (rx)  : ORIGIN = 0x5100000, LENGTH = 256K - 2 */ /* -2 for CRC16 */
  TCM (rwx) : ORIGIN = 0x40, LENGTH = 0x7FC0        /*32K - 64bytes Bytes*/
  /*SRAM (rwx) : ORIGIN = 0x5140000, LENGTH = 192K */ /*448K Bytes*/
  SRAM (rwx) : ORIGIN = 0x5100000, LENGTH = 0x70000 /*448K Bytes*/
}

__privileged_functions_region_size__  = 64K;  /*64K*/
__privileged_data_region_size__       = 32K;  /*64K*/

__FLASH_segment_start__               = ORIGIN(SRAM);
__FLASH_segment_end__                 = __FLASH_segment_start__ + 256K;

__SRAM_segment_start__                = ORIGIN(SRAM) + 256K;
__SRAM_segment_end__                  = __SRAM_segment_start__ + 192K;

__privileged_functions_start__        = __FLASH_segment_start__;
__privileged_functions_end__          = __FLASH_segment_start__ + __privileged_functions_region_size__;

__privileged_data_start__             = __SRAM_segment_start__;
__privileged_data_end__               = __SRAM_segment_start__ + __privileged_data_region_size__;

/* Specify the default entry point to the program */
ENTRY(__vector_table)

SECTIONS
{
    .privileged_functions :
    {
        . = ALIGN(4);
        KEEP(*(.intvecs))
        KEEP (*(.freertos_vectors))
        KEEP (*(.vectors))
        KEEP(*(.fw_infos_section))
        KEEP(*(.isr_vector)) /* Startup code. */
        . = ALIGN(4);
        *(privileged_functions)
        . = ALIGN(4);
        /* Fill rest of the region with a known value */
        FILL(0xADDEADDE);
        /* Ensure that non-privileged code is placed after the region reserved for
        * privileged kernel code. This is done for MPU Region Alignment */
        /* Note that dot (.) actually refers to the byte offset from the start of
        * the current section (.privileged_functions in this case). As a result,
        * setting dot (.) to a value sets the size of the section. */
        . = __privileged_functions_region_size__;
    } >SRAM

    .freertos_system_calls :
    {
        . = ALIGN(4);
        /* Place the FreeRTOS System Calls first in the unprivileged region. */
        __syscalls_flash_start__ = .;
        *(freertos_system_calls)
        __syscalls_flash_end__ = .;
        . = ALIGN(4);
    } >SRAM

    .text :
    {
        . = ALIGN(4);
        *(.boot)
        . = ALIGN(4);
        *(.text)
        *(.text.*)
        *(.gnu.linkonce.t.*)
        *(.plt)
        *(.gnu_warning)
        *(.gcc_execpt_table)
        *(.glue_7)
        *(.glue_7t)
        *(.vfp11_veneer)
        *(.ARM.extab)
        *(.gnu.linkonce.armextab.*)
    } > SRAM

    /* FreeRTOS kernel data. */
    .privileged_data :
    {
        . = ALIGN(4);
        *(privileged_data)
        . = ALIGN(4);
        _erelocate = .;
        /* FILL(0xDEAD); */
        /* Ensure that un-privileged data is placed after the region reserved
         * for privileged kernel data. */
        /* Note that dot (.) actually refers to the byte offset from the start
         * of the current section (.privileged_data in this case). As a result,
         * setting dot (.) to a value sets the size of the section. */
        . = __privileged_data_region_size__;
    } > SRAM

    .mem_tcm(NOLOAD) : ALIGN(4)
    {
        _tcm_start = .;
        KEEP (*(.mem_tcm))
        _tcm_end = .;
    } > TCM

    .init :
    {
        KEEP (*(.init))
    } > SRAM

    .fini :
    {
        KEEP (*(.fini))
    } > SRAM

    .interp :
    {
        KEEP (*(.interp))
    } > SRAM

    .note-ABI-tag :
    {
        KEEP (*(.note-ABI-tag))
    } > SRAM

    .ctors :
    {
        __CTOR_LIST__ = .;
        ___CTORS_LIST___ = .;
        KEEP (*crtbegin.o(.ctors))
        KEEP (*(EXCLUDE_FILE(*crtend.o) .ctors))
        KEEP (*(SORT(.ctors.*)))
        KEEP (*(.ctors))
        __CTOR_END__ = .;
        ___CTORS_END___ = .;
    } > SRAM

    .dtors :
    {
        __DTOR_LIST__ = .;
        ___DTORS_LIST___ = .;
        KEEP (*crtbegin.o(.dtors))
        KEEP (*(EXCLUDE_FILE(*crtend.o) .dtors))
        KEEP (*(SORT(.dtors.*)))
        KEEP (*(.dtors))
        __DTOR_END__ = .;
        ___DTORS_END___ = .;
    } > SRAM

    .fixup :
    {
        *(.fixup)
    } > SRAM

    .eh_frame :
    {
        *(.eh_frame)
    } > SRAM

    .eh_framehdr :
    {
        *(.eh_framehdr)
    } > SRAM

    .gcc_except_table :
    {
        *(.gcc_except_table)
    } > SRAM

    .rodata : ALIGN(4)
    {
        *(.rodata)
        *(.rodata.*)
        *(.gnu.linkonce.r.*)
    } > SRAM

    .rodata1 : ALIGN(4) {
        *(.rodata1)
        *(.rodata1.*)

        _shell_command_start = .;
        KEEP (*(shellCommand))
        _shell_command_end = .;
    } > SRAM

    .data : ALIGN(4)
    {
        *(.data)
        *(.data.*)
        *(.gnu.linkonce.d.*)
        *(.jcr)
        *(.got)
        *(.got.plt)
    } > SRAM

    .got :
    {
        *(.got)
    } > SRAM

    .mmu_tbl (ALIGN(16384)) :
    {
        *(.mmu_tbl)
    } > SRAM

    .ARM.exidx :
    {
        *(.ARM.exidx*)
        *(.gnu.linkonce.armexidix.*.*)
    } > SRAM

    .preinit_array :
    {
        KEEP (*(SORT(.preinit_array.*)))
        KEEP (*(.preinit_array))
    } > SRAM

    .init_array :
    {
        KEEP (*(SORT(.init_array.*)))
        KEEP (*(.init_array))
    } > SRAM

    .fini_array :
    {
        KEEP (*(SORT(.fini_array.*)))
        KEEP (*(.fini_array))
    } > SRAM

    .ARM.attributes :
    {
        *(.ARM.attributes)
    } > SRAM

    .sbss (NOLOAD) : ALIGN(4)
    {
        __sbss_start__ = .;
        *(.sbss)
        *(.sbss.*)
        __sbss_end__ = .;
    } > SRAM

    .bss (NOLOAD) : ALIGN(4)
    {
        __bss_start__ = .;
        *(.bss)
        *(.bss.*)
        *(.gnu.linkonce.b.*)
        *(COMMON)
        __bss_end__ = .;
    } > SRAM

    /* Allocate Stack and Heap definitions */
    .heap (NOLOAD) :
    {
        . = ALIGN(16);
        _heap = .;
        HeapBase = .;
        _heap_start = .;
        PROVIDE(end = .);
        . += _HEAP_SIZE;
        _heap_end = .;
        HeapLimit = .;
    } > SRAM

    .stack (NOLOAD) :
    {
        _stack_end = .;
        . += _STACK_SIZE;
        . = ALIGN(16);
        __sys_stack_start__ = .;

        _irq_stack_end = .;
        . += _IRQ_STACK_SIZE;
        . = ALIGN(16);
        __irq_stack_start__ = .;

        _supervisor_stack_end = .;
        . += _SUPERVISOR_STACK_SIZE;
        . = ALIGN(16);
        __supervisor_stack_start__ = .;

        _abort_stack_end = .;
        . += _ABORT_STACK_SIZE;
        . = ALIGN(16);
        __abort_stack_start__ = .;

        _fiq_stack_end = .;
        . += _FIQ_STACK_SIZE;
        . = ALIGN(16);
        __fiq_stack_start__ = .;

        _undef_stack_end = .;
        . += _UNDEF_STACK_SIZE;
        . = ALIGN(16);
        __undef_stack_start__ = .;
  } > SRAM
}