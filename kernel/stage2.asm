BITS 16
org 0x8000

start:
    cli 
    mov ax, 0x0000
    mov ss, ax
    mov sp, 0x6000
    
    mov ax, cs
    mov ds, ax
    ;mov ax, 0xB800
    ;mov es, ax
    ;xor di, di

    ; mov si, msg
    ; mov bl, 0x02

    call check_a20
    cmp ax, 1
    je continue

    ;enable a20 if not enabled
    in al, 0x92
    or al, 2
    out 0x92, al

continue:
    ;mov ax, 0xB800
    ;mov es, ax  ;move memory address of vram
    ;xor di, di  ;top left of screen
    ;mov si, a20_msg
    ;mov bl, 0x02
    mov ax, 0x1000
    mov es, ax
    mov ah, 0x02       ; BIOS function to read sectors
    mov al, 10          ; Number of sectors to read
    mov ch, 0          ; Cylinder number
    mov cl, 3         ; Sector number (starts at 1)
    mov dh, 0          ; Head number
    mov dl, [0x7E00]       ; Drive number (0x00 for first floppy)
    mov bx, 0x0000    ; Memory address to load the sector

    int 0x13
    push ax

    mov ax, 0xB800
    mov es, ax
    pop ax
    add ah, 0x30
    mov byte [es:0x00A2], ah
    mov byte [es:0x00A3], 0x04
    
    jc disk_error
    cli

    mov eax, cr0 ;load register into eax that enables PM
    or al, 1
    mov cr0, eax
    jmp 08h:PNodeMain ;set code segment and jump to pnodemain
    ;jmp .print

disk_error:
    mov ax, 0xB800      ;setting vram segment base address in ax to write to later
    mov es, ax          ;set extra segment to vram segment address
    mov si, disk_read_error ;load disk_read_error message in
    mov bl, 0x04        ;set text color to dark red
    call .error_print   ;
    jmp error_done

.error_print:
    lodsb
    cmp al, 0
    je done
    mov ah, bl
    stosw
    jmp .error_print

error_done:
    hlt


check_a20:
    pushf
    push ds
    push es
    push di
    push si

    cli

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
    je check_a20__exit

    mov ax, 1

check_a20__exit:
    pop si
    pop di
    pop es
    pop ds
    popf

    ret



BITS 32

PNodeMain:
    mov ax, 10h
    mov es, ax
    mov ds, ax
    mov ss, ax

    mov esp, 0x90000
    mov eax, 0x10000
    call eax

.hang:
    hlt
    jmp .hang

    
.print:
    lodsb
    cmp al, 0
    je done
    mov ah, bl
    stosw
    jmp .print

done:
    hlt





a20_msg db "a20 gate is enabled!", 0

disk_read_error:
    db "Disk Read Error. Halting.", 0;

BootDrive:
    db 0
times 512 - ($ - $$) db 0