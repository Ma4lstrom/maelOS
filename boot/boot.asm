BITS 16
org 0x7C00             ;assemble code as if it was at 0x7C00

_start:
    cli                 ;disable le interupts for now
    cld                 ;clear direction flag
    xor ax, ax          ;set base register to 0 so i can set others to 0
    mov ds, ax          ;set data segment to 0, all symbol offsets will be using this as a baseoffset i believe.
    xor di, di          ;index of vram buff address (this is top left index 0)
    mov [0x7E00], dl
    ;this sets up a stack so we can run c code as it wont function without a stack
    ;give the stack segment a segment base of 0x9000, this will be the segment base thats mult by
    ;16 = 0x90000. then set the top of the stack in stack pointer with 0xFFFF
    ;the stack will now grow down as stack is pushed, going down to 0x90000 from 0x9FFFF
    mov ax, 0x9000      ;set ax stack segment base in helper register
    mov ss, ax          ;move stack segment base into stack segment register
    mov sp, 0xFFFF      ;move into stack pointer the offset at which the top of the stack will be
   
    mov ah, 0x02        ; BIOS function to read sectors
    mov al, 1           ; Number of sectors to read
    mov ch, 0          ; Cylinder number
    mov cl, 2          ; Sector number (starts at 1)
    mov dh, 0          ; Head number
    mov dl, [0x7E00]     ; Drive number (0x00 for first floppy)
    mov bx, 0x8000     ; Memory address to load the sector
    
    lgdt [gdt_descriptor]
    int 0x13    ;call bios int
    jc disk_error
    
    
    jmp 0x0000:0x8000

    

print_string:
.next_char:
    lodsb               ;loads into al byte of si, then increments
    mov ah, bl          ;moves passed color from bl into ah      
    cmp al, 0           ;compares al to see if null term
    je done             ;if al = null term , jump to stack_init
    stosw               ;write to vram at di address, increment di afterwards.
    jmp .next_char      ;loop back to next char
done:
    ret

exit:
    hlt

disk_error:
    mov ax, 0xB800      ;setting vram segment base address in ax to write to later
    mov es, ax          ;set extra segment to vram segment address
    mov si, disk_read_error ;load disk_read_error message in
    mov bl, 0x04        ;set text color to dark red
    call print_string   ;
    jmp exit


disk_read_error:
    db "Disk Read Error. Halting.", 0;

BootDrive: db 0

;Byte:  0-1        2-3         4        5            6             7
;     [limit lo] [base lo] [base m] [access]  [flags+limit hi] [base hi]
gdt_start:
gdt_null:
    dq 0
gdt_code:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00
gdt_data:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

TIMES 510 - ($ - $$) DB 0       ;pad file upto last 2 bytes
DW 0xAA55       ;mbr boot signature needed to be recognized by bios