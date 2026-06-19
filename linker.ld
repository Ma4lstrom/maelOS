OUTPUT_FORMAT("binary")
ENTRY(kmain)

SECTIONS
{
    . = 0x10000;

    .text : {
        bin/kernel.o(.text) /* ensure kmain is at top */
        *(.text)  /* pulls and placed .text from ALL obj files. */
    }

    .data : {
        *(.data) /* pulls and placed .data from ALL obj files. */
    }

    .rodata : {
        *(.rodata)  /* pulls and places readonly data */
    }


    .bss : {
        *(.bss)
        *(COMMON)
    }
}