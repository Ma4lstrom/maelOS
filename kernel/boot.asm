org 0x7C00             ;assemble code as if it was at 0x7C00

_start:
    cli                 ;disable le interupts for now

    xor ax, ax          ;set base register to 0 so i can set others to 0
    mov ds, ax          ;set data segment to 0, all symbol offsets will be using this as a baseoffset i believe.
    mov ax, 0xB800      ;setting vram segment base address in ax to write to later
    mov es, ax          ;set extra segment to vram segment address

    xor di, di          ;index of vram buff address (this is top left index 0)

    ;this sets up a stack so we can run c code as it wont function without a stack
    ;give the stack segment a segment base of 0x9000, this will be the segment base thats mult by
    ;16 = 0x90000. then set the top of the stack in stack pointer with 0xFFFF
    ;the stack will now grow down as stack is pushed, going down to 0x90000 from 0x9FFFF
    mov ax, 0x9000      ;set ax stack segment base in helper register
    mov ss, ax          ;move stack segment base into stack segment register
    mov sp, 0xFFFF      ;move into stack pointer the offset at which the top of the stack will be

    mov si, stack_setup
    call print_string

    mov di, 160       ;move down 1 row to print next boot string 80 char lines
    mov si, boot_string
    call print_string

    jmp exit

print_string:
.next_char:
    lodsb               ;loads into al byte of si, then increments
    cmp al, 0           ;compares al to see if null term
    je done             ;if al = null term , jump to stack_init
    mov ah, 0x0A        ;fallout style, black background, bright green char
    stosw               ;write to vram at di address, increment di afterwards.
    jmp .next_char      ;loop back to next char
done:
    ret

exit:
    hlt

stack_setup:
    db "Stack initialized", 0;



boot_string:
    db "Booting into kernel later", 0;


TIMES 510 - ($ - $$) DB 0       ;pad file upto last 2 bytes
DW 0xAA55       ;mbr boot signature needed to be recognized by bios