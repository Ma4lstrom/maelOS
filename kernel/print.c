#include "print.h"

static inline void outb(unsigned short port, unsigned char val) {
    __asm__ volatile (
        "outb %0, %1"
        : 
        : "a"(val), "Nd"(port)
    );
}

void print(char* string) {
    volatile char * vga = (volatile char *)0xB8000;
    
    while(*string) {
        *(volatile unsigned short*)vga = (0x02 << 8) | *string; //write 0x02 green text black background into high bits and character value into low
        vga += 2;
        string++;
    }
}


void clear_screen() {
    volatile char * vga = (volatile char *)0xB8000;
    int i = 0;
    while(i < 2000) {
        *(volatile unsigned short*)vga = (0x02 << 8) | ' ';
        vga += 2;
        i++;
    }
}

void set_cursor(unsigned short pos) {
    outb(0x3D4, 0x0F);
    outb(0x3D5, (unsigned char)(pos & 0xFF)); //zero out the high bits (like using al in eax)

    outb(0x3D4, 0x0E);
    outb(0x3D5, (unsigned char)(pos >> 8) & 0xFF); //shift high bits down to low bits and make sure we only send 8 bits
}