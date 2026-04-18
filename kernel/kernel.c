#include "print.h"

void kmain(void) {
    clear_screen();
    print("Hi!");
    set_cursor(3);
    while (1) {
        __asm__ volatile("hlt");
    }
}