BITS 32
extern print
extern clear_screen

global kmain
kmain:
    push ebp
    mov ebp, esp

    call clear_screen
    push msg
    call print
    add esp, 4

    cli
    mov ecx, 256
    mov edi, idt

    .fill_idt:
        mov eax, isr_default
        
        mov word [edi + 0], ax
        mov word [edi + 2], 0x08
        mov byte [edi + 4], 0
        mov byte [edi + 5], 0x8E
        shr eax, 16
        mov word [edi + 6], ax

        add edi, 8
        loop .fill_idt
    lidt [idt_descriptor] ;loader IDT
    sti
    

.hang:
    hlt
    jmp .hang


isr_default:
    cli
    hlt
    jmp isr_default

idt:
    times 256 dq 0  ;256 entries, 8 bytes each
idt_descriptor:
    dw idt_end - idt - 1 ; size(limit)
    dd idt               ; 32 bit address
idt_end:

;interrupt_descriptor_entry:
;int_offset:
;   dw 0
;int_selector:
;    dw 08h
;int_null:
;    db 0
;int_type_attributes:
;    db 0
;int_offset_2:
;    dw 0

idt_entry_size equ 8

msg db "Hello from urMom!", 0