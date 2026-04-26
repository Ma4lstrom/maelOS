#include "print.h"

void kmain(void) {
    struct terminal t;
    t.x = 0;
    t.y = 0;
    t.buffer = (short *)0xB8000;
    t.color = (short)0x0F;
    clear_screen(&t);
    // short count_written = print(&t, "Hello Kern!\n");
    // print_num(&t, count_written);
    for(short i = 0; i < 30; i++) {
        print(&t, "Hello From MaelOS!\n");
    }
    while (1) {
        __asm__ volatile("hlt");
    }
}