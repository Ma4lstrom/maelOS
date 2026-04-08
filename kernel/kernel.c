

void kmain(void) {
    volatile char* vga = (volatile char*)0xB8000;

    vga[0] = 'H';
    vga[1] = 0x07;

    vga[2] = 'i';
    vga[3] = 0x07;

    while (1) {
        __asm__ __volatile__("hlt");
    }
}