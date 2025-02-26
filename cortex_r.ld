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
  TCM (rwx)       : ORIGIN = 0x40, LENGTH = 0x7FC0        /*32K - 64bytes Bytes*/
  FLASH (rx)      : ORIGIN = 0x5100000, LENGTH = 256K
  SRAM (rwx)      : ORIGIN = 0x5140000, LENGTH = 192K
}

__FLASH_segment_start__               = ORIGIN(FLASH);
__FLASH_segment_end__                 = __FLASH_segment_start__ + LENGTH(FLASH);

__SRAM_segment_start__                = ORIGIN(SRAM);
__SRAM_segment_end__                  = __SRAM_segment_start__ + LENGTH(SRAM);

__privileged_functions_region_size__  = 64K;
__privileged_functions_start__        = __FLASH_segment_start__;
__privileged_functions_end__          = __FLASH_segment_start__ + __privileged_functions_region_size__;

__privileged_data_region_size__       = 64K;
__privileged_data_start__             = __SRAM_segment_start__;
__privileged_data_end__               = __SRAM_segment_start__ + __privileged_data_region_size__;

/* A section of memory at the start of "PRIVILEGED_DATA" for different operating mode stacks */
__privileged_stacks_region_size__ = 2K;
__privileged_stacks_start__       = ORIGIN( SRAM );
__privileged_stacks_end__         = ORIGIN( SRAM ) + __privileged_stacks_region_size__;

/* Memory block for various dev kit peripherals */
__peripherals_start__   = 0x20000000;
__peripherals_length__  = 1536M;
__peripherals_end__     = __peripherals_start__ + __peripherals_length__;

/* Seperate memory block for privileged system */
/*__privileged_system_start__   = 0xFFF80000;*/
/*__privileged_system_length__  = 512K;*/
/*__privileged_system_end__     = __privileged_system_start__ + __privileged_system_length__;*/

/* The first 2K of space in RAM is used for different processor mode stacks */
__privileged_stack_region_size = 0x800;

/* Specify the default entry point to the program */
ENTRY(__vector_table)

SECTIONS
{
    .privileged_functions :
    {
        . = ALIGN(4);
        KEEP (*(.freertos_vectors))
        KEEP (*(.vectors))

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
    } >FLASH

    .freertos_system_calls :
    {
        . = ALIGN(4);
        /* Place the FreeRTOS System Calls first in the unprivileged region. */
        __syscalls_flash_start__ = .;
        *(freertos_system_calls)
        __syscalls_flash_end__ = .;
        . = ALIGN(4);
    } >FLASH

      /* This variable is used in portASM.S to determine if a FreeRTOS System Call
        * was raised from this specific section of flash */
    __syscalls_flash_length__ = __syscalls_flash_end__ - __syscalls_flash_start__;

    .text :
    {
        *(.boot)
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
        *(.eh_frame)
        KEEP (*(.init))
        KEEP (*(.fini))
        . = ALIGN(4);
        _etext = .;        /* define a global symbols at end of code */
    } > FLASH

    .mem_tcm(NOLOAD) : ALIGN(4)
    {
        _tcm_start = .;
        KEEP (*(.mem_tcm))
        _tcm_end = .;
    } > TCM

    .interp :
    {
        KEEP (*(.interp))
    } > FLASH

    .note-ABI-tag :
    {
        KEEP (*(.note-ABI-tag))
    } > FLASH

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
    } > FLASH

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
    } > FLASH

    .fixup :
    {
        *(.fixup)
    } > FLASH

    .eh_framehdr :
    {
        *(.eh_framehdr)
    } > FLASH

    .gcc_except_table :
    {
        *(.gcc_except_table)
    } > FLASH

    .rodata : ALIGN(4)
    {
        *(.rodata)
        *(.rodata.*)
        *(.gnu.linkonce.r.*)
    } > FLASH

    .rodata1 : ALIGN(4) {
        *(.rodata1)
        *(.rodata1.*)

        _shell_command_start = .;
        KEEP (*(shellCommand))
        _shell_command_end = .;
    } > FLASH

    .privileged_data :
    {
        /* Leave a block of memory for different Processor mode stacks.
        * These are set in sys_core.S */
        . = ALIGN(4);
        /* Mark the start of the region for debugging purposes. */
        __start_privileged_stack_region = .;
        . = __privileged_stack_region_size;
        . = ALIGN(4);
        /* Mark the end of the region for debugging purposes. */
        __end_privileged_stack_region = .;

        __start_priv_data = .; /* Create a global symbol at privileged data start. */
        *(privileged_data)
        . = ALIGN(4);
        __end_priv_data = .; /* Create a global symbol at privileged data end. */
        FILL(0xADDE); /* Fill RAM with known value */
        /* Ensure that non-privileged data is placed after the region reserved for
        * privileged kernel data. */
        /* Note that dot (.) actually refers to the byte offset from the start of
        * the current section (.privileged_data in this case). As a result, setting
        * dot (.) to a value sets the size of the section. */
        . = __privileged_data_region_size__;
        . = ALIGN(4);
    } >SRAM

    .data : ALIGN(4)
    {
        *(.data)
        *(.data.*)
        *(.gnu.linkonce.d.*)
        *(.jcr)
        *(.got)
        *(.got.plt)
    } >SRAM

    .got :
    {
        *(.got)
    } > FLASH

    .mmu_tbl (ALIGN(16384)) :
    {
        *(.mmu_tbl)
    } > FLASH

    .ARM.exidx :
    {
        *(.ARM.exidx*)
        *(.gnu.linkonce.armexidix.*.*)
    } > FLASH

    .preinit_array :
    {
        KEEP (*(SORT(.preinit_array.*)))
        KEEP (*(.preinit_array))
    } > FLASH

    .init_array :
    {
        KEEP (*(SORT(.init_array.*)))
        KEEP (*(.init_array))
    } > FLASH

    .fini_array :
    {
        KEEP (*(SORT(.fini_array.*)))
        KEEP (*(.fini_array))
    } > FLASH

    .ARM.attributes :
    {
        *(.ARM.attributes)
    } > FLASH

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