.GLOBAL ResetHandler
.GLOBAL __sys_stack_start__
.GLOBAL __irq_stack_start__
.GLOBAL __supervisor_stack_start__
.GLOBAL __abort_stack_start__
.GLOBAL __fiq_stack_start__
.GLOBAL __undef_stack_start__

.EXTERN __sbss_start__
.EXTERN __sbss_end__
.EXTERN __bss_start__
.EXTERN __bss_end__

//---------------------------------------------------------------- 
//CPSR Macros
//---------------------------------------------------------------- 
.EQU CPSR_MODE_USR,        0x10
.EQU CPSR_MODE_FIQ,        0x11
.EQU CPSR_MODE_IRQ,        0x12
.EQU CPSR_MODE_SVC,        0x13
.EQU CPSR_MODE_ABT,        0x17
.EQU CPSR_MODE_UND,        0x1B
.EQU CPSR_MODE_SYS,        0x1F

.section .boot,"axS"
ResetHandler:
//----------------------------------------------------------------
// Initialize processor registers to 0
//----------------------------------------------------------------
	MOV	r0,#0
	MOV	r1,#0
	MOV	r2,#0
	MOV	r3,#0
	MOV	r4,#0
	MOV	r5,#0
	MOV	r6,#0
	MOV	r7,#0
	MOV	r8,#0
	MOV	r9,#0
	MOV	r10,#0
	MOV	r11,#0
	MOV	r12,#0

//----------------------------------------------------------------
// Disable MPU and caches
//----------------------------------------------------------------

// Disable MPU and cache in case it was left enabled from an earlier run
// This does not need to be done from a cold reset

        MRC     p15, 0, r0, c1, c0, 0       // Read System Control Register
        BIC     r0, r0, #0x05               // Disable MPU (M bit) and data cache (C bit)
        BIC     r0, r0, #0x1000             // Disable instruction cache (I bit)
        DSB                                 // Ensure all previous loads/stores have completed
        MCR     p15, 0, r0, c1, c0, 0       // Write System Control Register
        ISB                                 // Ensure subsequent insts execute wrt new MPU settings

//----------------------------------------------------------------
// Disable Branch prediction
//----------------------------------------------------------------

// In the Cortex-R5, the Z-bit of the SCTLR does not control the program flow prediction.
// Some control bits in the ACTLR control the program flow and prefetch features instead.
// These are enabled by default, but are shown here for completeness.

        MRC     p15, 0, r0, c1, c0, 1       // Read ACTLR
        ORR     r0, r0, #(0x1 << 17)        // Enable RSDIS bit 17 to disable the return stack
        ORR     r0, r0, #(0x1 << 16)        // Clear BP bit 15 and set BP bit 16:
        BIC     r0, r0, #(0x1 << 15)        // Branch always not taken and history table updates disabled
        MCR     p15, 0, r0, c1, c0, 1       // Write ACTLR
        ISB

//----------------------------------------------------------------
// Setup Stacks
//----------------------------------------------------------------
        CPS #CPSR_MODE_FIQ
        LDR sp, = __fiq_stack_start__

        CPS #CPSR_MODE_IRQ
        LDR sp, = __irq_stack_start__

        CPS #CPSR_MODE_SVC
        LDR sp, = __supervisor_stack_start__

        CPS #CPSR_MODE_ABT
        LDR sp, = __abort_stack_start__

        CPS #CPSR_MODE_UND
        LDR sp, = __undef_stack_start__

        CPS #CPSR_MODE_SYS
        LDR sp, = __sys_stack_start__
#if 0
        MRC     p15, 0, r0, c0, c0, 5                 @ Read CPU ID register
        ANDS    r0, r0, #0x03                         @ Mask off, leaving the CPU ID field
        
        MOV     r1, #CPSR_MODE_FIQ                    @ Build FIQ mode CPSR
        MSR     CPSR_c, r1                            @ Enter FIQ mode
        LDR     r1, =__fiq_stack_start__              @ FIQ stacks for CPU 0,1
        SUB     r1, r1, r0, LSL #10                   @ 512 bytes of FIQ stack per CPU (0,1) - see *.ld
        MOV     sp, r1

        MOV     r1, #CPSR_MODE_IRQ                    @ Build IRQ mode CPSR
        MSR     CPSR_c, r1                            @ Enter IRQ mode
        LDR     r1, =__irq_stack_start__              @ IRQ stacks for CPU 0,1
        SUB     r1, r1, r0, LSL #10                   @ 512 bytes of IRQ stack per CPU (0,1) - see *.ld
        MOV     sp, r1

        MOV     r2, #CPSR_MODE_SVC                    @ Build SVC mode CPSR
        MSR     CPSR_c, r2                            @ Enter SVC mode
        LDR     r1, =__supervisor_stack_start__       @ App stacks for all CPUs
        SUB     r1, r1, r0, LSL #10                   @ 512 bytes of App stack per CPU - see *.ld
        MOV     sp, r1

        MOV     r2, #CPSR_MODE_ABT                    @ Build ABT mode CPSR
        MSR     CPSR_c, r2                            @ Enter ABT mode
        LDR     r1, =__abort_stack_start__            @ App stacks for all CPUs
        SUB     r1, r1, r0, LSL #10                   @ 512 bytes of App stack per CPU - see *.ld
        MOV     sp, r1

        MOV     r2, #CPSR_MODE_UND                    @ Build UND mode CPSR
        MSR     CPSR_c, r2                            @ Enter UND mode
        LDR     r1, =__undef_stack_start__            @ App stacks for all CPUs
        SUB     r1, r1, r0, LSL #10                   @ 512 bytes of App stack per CPU - see *.ld
        MOV     sp, r1

        MOV     r2, #CPSR_MODE_SYS                    @ Build SYS mode CPSR
        MSR     CPSR_c, r2                            @ Enter SYS mode
        LDR     r1, =__sys_stack_start__              @ App stacks for all CPUs
        SUB     r1, r1, r0, LSL #13                   @ 0x1000 bytes of App stack per CPU - see *.ld
        MOV     sp, r1
#endif

//----------------------------------------------------------------
// Cache invalidation
//----------------------------------------------------------------

        DSB                 // Complete all outstanding explicit memory operations
        MOV     r0, #0
        MCR     p15, 0, r0, c7, c5, 0       // Invalidate entire instruction cache
        MCR     p15, 0, r0, c15, c5, 0      // Invalidate entire data cache

//----------------------------------------------------------------
// MPU Configuration
//----------------------------------------------------------------

// Notes:
// * Regions apply to both instruction and data accesses.
// * Each region base address must be a multiple of its size
// * Any address range not covered by an enabled region will abort
// * The region at 0x0 over the Vector table is needed to support semihosting

#if 1
//init mpu region 0,Device 256M          0~0x10000000 （R0）
        MOV    r0, #13                    //region 13
        MOV    r3, #0                     //base addr from 0
//      MOV    r1,#0x310                  //tex[5:3],ap[10:8],c=0,b=0,ap=3    ap=3,read+write,tex=2,non-share device
        MOV    r1,#0x30F                  //tex[5:3],ap[10:8],c=0,b=0,ap=3    ap=3,read+write,tex=1,normal(no cache)
//      MOV    r1,#0x608                  //tex[5:3],ap[10:8],c=0,b=0,ap=6    ap=6,read only, tex=1,normal(no cache)
        MOV    r2,#0x37                   //size 256M,enable
        MCR    p15,0,r0,c6,c2,0           // Set region number
        MCR    p15,0,r3,c6,c1,0           // Region base address         
        MCR    p15,0,r1,c6,c1,4           // Region access control        
        MCR    p15,0,r2,c6,c1,2           // Region size and enable 

//init mpu region 1,Device 1G          0x10000000~0x50000000 （R0）
        MOV    r0, #12                    //region 12 
        MOV    r3, #0x10000000            //base addr from 0
        MOV    r1,#0x301                  //normal,tex[5：3] 001 ,c=0,b=0,ap=3
        MOV    r2,#0x3B                   //size 1G,enable
        MCR    p15,0,r0,c6,c2,0           // Set region number
        MCR    p15,0,r3,c6,c1,0           // Region base address         
        MCR    p15,0,r1,c6,c1,4           // Region access control        
        MCR    p15,0,r2,c6,c1,2           // Region size and enable 
        
//init mpu region 2,rom sram 128M          0x18000000~0x20000000 （rw）
//        MOV    r0, #2                     //region 1
//        MOV    r3, #0x18000000            //base addr from 0
//        MOV    r1,#0x30F                  //normal,tex[5：3] 001 ,c=0,b=0,ap=3
//        MOV    r2,#0x25                   //size 512K,enable
//        MCR    p15,0,r0,c6,c2,0           // Set region number
//        MCR    p15,0,r3,c6,c1,0           // Region base address         
//        MCR    p15,0,r1,c6,c1,4           // Region access control        
//        MCR    p15,0,r2,c6,c1,2           // Region size and enable             


//init mpu region 3,Device 512M          0x20000000~0x40000000 （R0）
//        MOV    r0, #3                     // region 0
//        MOV    r3, #0x20000000            // base addr from 0x20000000 
//        MOV    r1,#0x310                  // share device,tex[3] 000 ,c=0,b=1,ap=3
//        MOV    r2,#0x39                   // size 512M,enable    
//        MCR    p15,0,r0,c6,c2,0           // Set region number
//        MCR    p15,0,r3,c6,c1,0           // Region base address         
//        MCR    p15,0,r1,c6,c1,4           // Region access control        
//        MCR    p15,0,r2,c6,c1,2           // Region size and enable 
    
//init mpu region 4,Device 512M          0x30000000~0x40000000 （R0）
//        MOV    r0, #4                     // region 0
//        MOV    r3, #0x30000000            // base addr from 0x20000000 
//        MOV    r1,#0x301                  // share device,tex[3] 000 ,c=0,b=1,ap=3
//        MOV    r2,#0x37                   // size 512M,enable    
//        MCR    p15,0,r0,c6,c2,0           // Set region number
//        MCR    p15,0,r3,c6,c1,0           // Region base address         
//        MCR    p15,0,r1,c6,c1,4           // Region access control        
//        MCR    p15,0,r2,c6,c1,2           // Region size and enable 
        
//init mpu region 4,Device 1G         0x40000000~0x80000000 （R0）
        MOV    r0, #14                    // region 14
        MOV    r3, #0x40000000            // base addr from 0x20000000 
        MOV    r1,#0x301                  // share device,tex[3] 000 ,c=0,b=1,ap=3
        MOV    r2,#0x3B                   // size 1G,enable    
        MCR    p15,0,r0,c6,c2,0           // Set region number
        MCR    p15,0,r3,c6,c1,0           // Region base address         
        MCR    p15,0,r1,c6,c1,4           // Region access control        
        MCR    p15,0,r2,c6,c1,2           // Region size and enable 

//init mpu region 5,DDR  2G           0x80000000~0x1 00000000 （R0）
        MOV    r0, #15                    // region 15
        MOV    r3, #0x80000000            // base addr from 0x80000000 
        MOV    r1,#0x308                  // share device,tex[3] 000 ,c=0,b=1,ap=3
        MOV    r2,#0x3d                   // size 2G,enable    
        MCR    p15,0,r0,c6,c2,0           // Set region number
        MCR    p15,0,r3,c6,c1,0           // Region base address         
        MCR    p15,0,r1,c6,c1,4           // Region access control        
        MCR    p15,0,r2,c6,c1,2           // Region size and enable 

//init mpu region 5,DDR  2G           0x80000000~0x1 00000000 （R0）
//        MOV    r0, #7                     // region 0
//        MOV    r3, #0xc0000000            // base addr from 0x20000000 
//        MOV    r1,#0x301                  // share device,tex[3] 000 ,c=0,b=1,ap=3
//        MOV    r2,#0x3b                   // size 2G,enable    
//        MCR    p15,0,r0,c6,c2,0           // Set region number
//        MCR    p15,0,r3,c6,c1,0           // Region base address         
//        MCR    p15,0,r1,c6,c1,4           // Region access control        
//        MCR    p15,0,r2,c6,c1,2           // Region size and enable
#endif
#if __ARM_FP  //def __ARM_FP
//----------------------------------------------------------------
// Enable access to VFP by enabling access to Coprocessors 10 and 11.
// Enables Full Access i.e. in both privileged and non privileged modes
//----------------------------------------------------------------

        MRC     p15, 0, r0, c1, c0, 2      // Read Coprocessor Access Control Register (CPACR)
        ORR     r0, r0, #(0xF << 20)       // Enable access to CP 10 & 11
        MCR     p15, 0, r0, c1, c0, 2      // Write Coprocessor Access Control Register (CPACR)
        ISB

//----------------------------------------------------------------
// Switch on the VFP hardware
//----------------------------------------------------------------
        MOV     r0, #0x40000000
        VMSR    FPEXC, r0                   // Write FPEXC register, EN bit set
#endif

//----------------------------------------------------------------
// Enable Branch prediction
//----------------------------------------------------------------

// In the Cortex-R5, the Z-bit of the SCTLR does not control the program flow prediction. 
// Some control bits in the ACTLR control the program flow and prefetch features instead.
// These are enabled by default, but are shown here for completeness.

        MRC     p15, 0, r0, c1, c0, 1       // Read ACTLR
        BIC     r0, r0, #(0x1 << 17)        // Clear RSDIS bit 17 to enable return stack
        BIC     r0, r0, #(0x1 << 16)        // Clear BP bit 15 and BP bit 16:
        BIC     r0, r0, #(0x1 << 15)        // Normal operation, BP is taken from the global history table.
        MCR     p15, 0, r0, c1, c0, 1       // Write ACTLR
        ISB

//----------------------------------------------------------------
// Enable MPU and branch to C library init
// Leaving the caches disabled until after scatter loading.
//----------------------------------------------------------------

        MRC     p15, 0, r0, c1, c0, 0       // Read System Control Register
        ORR     r0, r0, #0x01               // Set M bit to enable MPU
        DSB                                 // Ensure all previous loads/stores have completed
        MCR     p15, 0, r0, c1, c0, 0       // Write System Control Register
        ISB                                 // Ensure subsequent insts execute wrt new MPU settings

//----------------------------------------------------------------
//Warm Start-Up Check & .(s)bss initialization
//----------------------------------------------------------------
        MRC     p15, 0, r0, c0, c0, 5     @ Read CPU ID register
        ANDS    r0, r0, #0x03             @ Mask off, leaving the CPU ID field
        BEQ     clear_sbss_bss_data
        BNE     .Lend_bss
clear_sbss_bss_data:
        MOV r0, #0
/* Clear .sbss */
        LDR r1, =__sbss_start__
        LDR r2, =__sbss_end__
.Lloop_sbss:
        CMP r1, r2
/* If no .sbss, no clearing required */
        BGE .Lend_sbss
        STR r0, [r1], #4
        B .Lloop_sbss
.Lend_sbss:

/* Clear .bss */
        LDR r1, =__bss_start__
        LDR r2, =__bss_end__
.Lloop_bss:
        CMP r1, r2
/* If no .bss, no clearing required */
        BGE .Lend_bss
        STR r0, [r1], #4
        B .Lloop_bss
.Lend_bss:

/* Clear tcm */
        LDR r1, =_tcm_start
        LDR r2, =_tcm_end
.Lloop_tcm:
        CMP r1, r2
/* If no .tcm, no clearing required */
        BGE .LEnd_tcm
        STR r0, [r1], #4
        B .Lloop_tcm
.LEnd_tcm:

//----------------------------------------------------------------
// enable tcm and cache ecc
//----------------------------------------------------------------
        MRC     p15, 0, r0, c1, c0, 1       // Read ACTLR
        ORR     r0, r0, #0x2000000          //enable tcm ECC
        DSB
        MCR     p15, 0, r0, c1, c0, 1       // Write ACTLR
        ISB

//----------------------------------------------------------------
// enable asynchronous abort exception 
//----------------------------------------------------------------
	MRS	r0, cpsr
	BIC	r0, r0, #0x100
	MSR	cpsr_xsf, r0


//----------------------------------------------------------------
// enter start up code 
//----------------------------------------------------------------
    .GLOBAL     _startup
        MRC     p15, 0, r0, c0, c0, 5     @ Read CPU ID register
        ANDS    r0, r0, #0x03             @ Mask off, leaving the CPU ID field
        BEQ     _startup
.Ldone:	
        B	.Ldone			/* Paranoia: we should never get here */


//----------------------------------------------------------------
// Global Enable for Instruction and Data Caching
//----------------------------------------------------------------

    .global enable_caches

    .type enable_caches, "function"
    .cfi_startproc
enable_caches:

        MRC     p15, 0, r0, c1, c0, 0       // Read System Control Register
        ORR     r0, r0, #(0x1 << 12)        // enable I Cache
        ORR     r0, r0, #(0x1 << 2)         // enable D Cache
        MCR     p15, 0, r0, c1, c0, 0       // Write System Control Register
        ISB

        BX    lr
    .cfi_endproc

    .size enable_caches, . - enable_caches

.end
