#include "print.h"
#define VGA_WIDTH 80
#define VGA_HEIGHT 25

struct terminal {
    short x;
    short y;
    short * buffer;
    short color;
};

 // apparently inline asm in gcc is at&t syntax, so im documenting this for later
static inline void outb(unsigned short port, unsigned char val) {
    __asm__ volatile (
        "outb %0, %1"
        : 
        : "a"(val), "Nd"(port)
    ); 
}

static inline void outw(unsigned short port, unsigned short val) {
    __asm__ volatile (
        "outw %0, %1"
        :
        : "a"(val), "Nd"(port)
    );
}

static inline unsigned char inb(unsigned short port) {
    unsigned char ret;

    __asm__ volatile (
        "inb %1, %0"
        : "=a"(ret)
        : "Nd"(port)
    );

    return ret;
}

static inline unsigned short inw(unsigned short port) {
    unsigned short ret;
    
    __asm__ volatile (
        "inw %1, %0"
        : "=a"(ret)
        : "Nd"(port)
    );

    return ret;
}
 

void putchar(struct terminal* t, char c) {
    if (c == '\n') {
        t->x = 0;
        t->y += 1;
        set_cursor(t->y * VGA_WIDTH + t->x);
        return;
    }

    short position = t->y * VGA_WIDTH + t->x; //position of cursor
    t->buffer[position] = (t->color << 8) | c;

    t->x++;

    if (t->x >= VGA_WIDTH) {
        t->x = 0;
        t->y++;
    }
    set_cursor(t->y * VGA_WIDTH + t->x);
    return;

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
    set_cursor(0);
}

void set_cursor(unsigned short pos) {
    outb(0x3D4, 0x0F);
    outb(0x3D5, (unsigned char)(pos & 0xFF)); //zero out the high bits (like using al in eax)

    outb(0x3D4, 0x0E);
    outb(0x3D5, (unsigned char)(pos >> 8) & 0xFF); //shift high bits down to low bits and make sure we only send 8 bits
}