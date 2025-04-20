/* Linker Scripts Contain 4 things
    - Memory Layout : what memory is available where.
    - Section definitions : what part of a program should go where.
    - Options : commands to specify architecture, entry point, ect.
    - Symbols : variables to inject into the program at link time.

    Notes:
    - There are no rules for how many sections you can have, 
    - Typically want to put symbols in the same secion if
        - They should be in same region or memory
        - They need to be initialized together
    - 2 different types of symbols initialized in bulk
        - initalized static variables which must be copied from flash
        - uninitialized static variables which must be zeroed
    - linker concerns itself with 2 more things
        - code and constant data, which live in read only memory like flash
        - reserved sections of RAM like stack or heap
    - by convention we name those sections
        - .text  : for code and constants
        - .bss   : for unitialized data
        - .data  : for initialzed data
        - .stack : for our stack
*/

/* STM32F446RE Linker Script */ 

MEMORY                                                  /* NAME is optional, as well as (attr) */
{                                                       /* Found in datasheet pg1. top */
    FLASH (rx)  : ORIGIN = 0x08000000, LENGTH = 512k    /* r : Readable, x: executable, 512k, the k is ok to use  */
    RAM   (rwx) : ORIGIN = 0x20000000, LENGTH = 128k    /* r : Readable, w: Writable, x: executable  */
}

_estack = ORIGIN(RAM) + LENGTH(RAM);

ENTRY(Reset_Handler)                                    /* Tells Linker entry of program, called first on MCU Boot */

SECTIONS
{
    .isr_vector :
    {
        KEEP(*(.isr_vector))
    } > FLASH

    .text :                                             /* places isr_vector on top of FLASH */
    {                                                   /* The * in this case means to apply this rule to all input sections from all object files */
                                                        /* Interupt Vector Table */
        *(.text*)                                       /* Program code */
        *(.rodata*)                                     /* Read Only Data  */
        _etext = .;
    } > FLASH                                           /* The > means put into FLASH memory */

    .data : AT(_etext)                                  /* Section holds variables like int count = 5, char msg[] = hello; */
    {                                                   /* Variables live in RAM at address .text(AT(_etext)) */
        _sdata = .;                                     /* uses _sdata and _edata to mark where to copy from */
        *(.data*)                                       /* Initialized Variables */
        _edata = .;
    } > RAM

    .bss :                                              /* holds things like int counter; and char buffer[128]; */
    {                                                   /* these dont have initial values in flash */
        _sbss = .;                                      /* they just get zeroed out by ram, _sbss and _ebss is start and end */
        *(.bss*)                                        /* Unitialized Variables */
        *(COMMON)
        _ebss = .;
    } > RAM 

   . = ALIGN(8);
   _end = .;

}