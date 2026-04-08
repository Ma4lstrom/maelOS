BITS 16
org 0x8000

start:
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
    mov eax, cr0 ;load register into eax that enables PM
    or al, 1
    mov cr0, eax
    jmp 08h:PNodeMain
    ;jmp .print



BITS 32
extern kmain
PNodeMain:
    mov ax, 10h
    mov es, ax
    mov ds, ax
    mov di, ax
    mov ss, ax

    mov esp, 0x90000

    call kmain

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


a20_msg db "a20 gate is enabled!", 0

times 512 - ($ - $$) db 0