/*
    Summary:
    - Define the vector table       : So the MCU knows where to jump for exceptions and interrupts
    - Set up memory                 : Copy .data from Flash to RAM and clear .bss section
    - Initialize the stack          : Done using _estack as the starting stack pointer
    - Start main()                  : Begin program execution after memory initialization
    - Set fallbacks for unused IRQs : Redirect to infinite loop to prevent hard crashes

    Keywords to remember:
    - .data : Holds initialized global/static variables and constants; lives in Flash but runs in RAM
    - .bss  : Holds uninitialized global/static variables; zeroed in RAM at startup
              e.g., static int g_myglobal = 0; → goes in .bss
    - .text : Contains actual program code and constants; marked global to expose to linker
*/




.syntax unified                                 // use unified arm syntax
.cpu cortex-m4                                  // tell assembler were using cortex-m4
.thumb                                          // all stm32 code runs in thumb mode(compressed 16 bit instructions)

.section .isr_vector, "a", %progbits            // place vector table in own section
.global _vector_table
.type _vector_table, %object                    // .type / .size : metadata tells linker its object of known size
.size _vector_table, . - _vector_table


_vector_table:                                  // Vector table (16 entries minimum for Cortex-M)
    .word _estack                               // Initial Stack Pointer        --> 0x00000000
    .word Reset_Handler                         // Reset Handler                --> 0x00000004
    .word NMI_Handler                           // NMI Handler                  --> 0x00000008
    .word HardFault_Handler                     // Hard Fault Handler           --> 0x0000000C
    .word 0                                     // Memory Management Fault      --> 0x00000010
    .word 0                                     // Bus Fault                    --> 0x00000014
    .word 0                                     // Usage Fault                  --> 0x00000018
    .word 0                                     // Reserved                     --> 0x0000001C
    .word 0                                     // Reserved                     --> 0x00000020
    .word 0                                     // Reserved                     --> 0x00000024
    .word 0                                     // Reserved                     --> 0x00000028
    .word SVC_Handler                           // SVCall Handler               --> 0x0000002C
    .word 0                                     // Debug Monitor                --> 0x00000030
    .word 0                                     // Reserved                     --> 0x00000034
    .word PendSV_Handler                        // PendSV Handler               --> 0x00000038
    .word SysTick_Handler                       // SysTick Handler              --> 0x0000003C

.section .text                                  // tells kernel where code section starts
.global Reset_Handler                           // .text used for keeping the actual code
.type Reset_Handler, %function                  // using the .global to export the function

Reset_Handler:                                  // Copy .data from flash to RAM
    ldr r0, =_sdata                             // ram start of .data
    ldr r1, = _etext                            // flash end of .text (start of .data in flash)
    ldr r2, =_edata                             // ram end of .data
.data_copy:                                     
    cmp r0, r2                                  // needed because initialized variables live in flash but run in ram
    ittt lt
    ldrlt r3, [r1], #4
    strlt r3, [r0], #4
    blt .data_copy
                                                // Zero .bss                                
    ldr r0, =_sbss                              // this load start of .bss in ram
    ldr r1, =_ebss                              // this load register 1 with end of .bss 
    movs r2, #0
.bss_clear:                                     
    cmp r0, r1
    it lt
    strlt r2, [r0], #4
    blt .bss_clear

    bl main                                     // branch with link to main to run our main code

infinite_loop:                                  // if main exits, loop so chip doesnt crash
    b infinite_loop

// dummy handlers for interrupts (Can be over ridden in C)                
// .weak allows us to overwrite later if needed
.weak NMI_Handler, HardFault_Handler, SVC_Handler, PendSV_Handler, SysTick_Handler
.thumb_set NMI_Handler, infinite_loop
.thumb_set HardFault_Handler, infinite_loop
.thumb_set SVC_Handler, infinite_loop
.thumb_set PendSV_Handler, infinite_loop
.thumb_set SysTick_Handler, infinite_loop
