BITS 16
org 0x7C00             ;assemble code as if it was at 0x7C00

_start:
    cli                 ;disable le interupts for now
    mov [BootDrive], dl
    xor ax, ax          ;set base register to 0 so i can set others to 0
    mov ds, ax          ;set data segment to 0, all symbol offsets will be using this as a baseoffset i believe.
    xor di, di          ;index of vram buff address (this is top left index 0)

    ;this sets up a stack so we can run c code as it wont function without a stack
    ;give the stack segment a segment base of 0x9000, this will be the segment base thats mult by
    ;16 = 0x90000. then set the top of the stack in stack pointer with 0xFFFF
    ;the stack will now grow down as stack is pushed, going down to 0x90000 from 0x9FFFF
    mov ax, 0x9000      ;set ax stack segment base in helper register
    mov ss, ax          ;move stack segment base into stack segment register
    mov sp, 0xFFFF      ;move into stack pointer the offset at which the top of the stack will be

    ;load One sector width of sector 2 on cyl 0 head 0, on first HardDrive.
    ; mov dl, [BootDrive]
    ; mov ah, 0x02
    ; mov al, 0x01
    ; mov ch, 0x00
    ; mov cl, 0x02
    ; mov dh, 0x00
    ; mov bx, 0x1000

    ;mov ax, 0x0000
    ;mov es, ax

    ;int 0x13    ;call bios int
    
    ;jc disk_error       ;if carryflag, jumping to disk error. Means error.
    
    call check_a20
    cmp ax, 1

    mov ax, 0xB800      ;setting vram segment base address in ax to write to later
    mov es, ax          ;set extra segment to vram segment address
    mov bl, 0x0A        ;set bl to black bg, green text fallout style to pass to print_string
    jne a20_off_print
    mov si, boot_string
    call print_string

    jmp exit

a20_off_print:
    mov si, a20_not_ena_print

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


check_a20:
    ; returns 1 in ax register if a20 is enabled and 0 if not enabled
    pushf
    push ds
    push es
    push di
    push si

    cli
    ; xor turns any bit thats not the same as the others to 1
    xor ax, ax ; ax = 0
    mov es, ax 

    not ax ; ax = 0xFFFF
    mov ds, ax 

    mov di, 0x0500
    mov si, 0x0510

    mov al, byte [es:di]
    push ax

    mov al, byte [ds:si]
    push ax

    mov byte [es:di], 0x00
    mov byte [ds:si], 0xFF

    cmp byte [es:di], 0xFF

    pop ax
    mov byte [ds:si], al

    pop ax
    mov byte [es:di], al

    mov ax, 0
    je check_a20_exit

    mov ax, 1
check_a20_exit:
    pop si
    pop di
    pop es
    pop ds
    popf

    ret

boot_string:
    db "A20 line enabled already.", 0;

a20_not_ena_print:
    db "A20 line is disabled, enable please.", 0;

disk_read_error:
    db "Disk Read Error. Halting.", 0;

BootDrive: db 0

TIMES 510 - ($ - $$) DB 0       ;pad file upto last 2 bytes
DW 0xAA55       ;mbr boot signature needed to be recognized by bios