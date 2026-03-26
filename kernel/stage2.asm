BITS 16
org 0x1000

start:
    mov ax, cs
    mov ds, ax
    mov ax, 0xB800
    mov es, ax
    xor di, di

    mov si, msg
    mov bl, 0x0F

.print:
    lodsb
    cmp al, 0
    je done
    mov ah, bl
    stosw
    jmp .print

done:
    hlt

msg db "Hello from Stage 2!", 0

times 512 - ($ - $$) db 0