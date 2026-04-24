#include "print.h"

void kmain(void) {
    struct terminal t;
    t.x = 0;
    t.y = 0;
    t.buffer = (short *)0xB8000;
    t.color = (short)0x0F;
    clear_screen();
    putchar(&t, 'U');
    putchar(&t, 'R');
    putchar(&t, ' ');
    putchar(&t, 'M');
    putchar(&t, 'O');
    putchar(&t, 'M');
    while (1) {
        __asm__ volatile("hlt");
    }
}