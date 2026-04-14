BITS 32
global print
global clear_screen

print:
    push ebp
    mov ebp, esp
    push esi
    push edi
    mov esi, [ebp+8]
    mov edi, 0xB8000
    cld
print_loop:
    lodsb
    test al, al
    jz .done
    mov [edi], al
    mov byte [edi+1], 0x02
    add edi, 2
    jmp print_loop
.done:
    pop edi
    pop esi
    pop ebp
    ret


print_int:
    push edi
    push esi 

clear_screen:
    push edi
    push esi
    push eax
    mov al, 0x00
    mov edi, 0xB8000
    mov esi, 0
clear_loop:
    add esi, 1
    mov [edi], al
    mov byte [edi+1], 0x04
    add edi, 2
    cmp esi, 2000
    je .done
    jmp clear_loop
.done:
    mov dx, 0x3D4
    mov al, 0x0F
    out dx, al
    mov dx, 0x3D5
    mov al, 0x0
    out dx, al

    mov dx, 0x3D4
    mov al, 0x0E
    out dx, al
    mov dx, 0x3D5
    mov al, 0x0
    out dx, al

    pop eax
    pop esi
    pop edi
    ret


