#include "print.h"

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
        if (t->y == VGA_HEIGHT) {
            t->x = 0;
            t->y = 0;
            t->buffer = (short *)0xB8000;
        }
    }
    set_cursor(t->y * VGA_WIDTH + t->x);
    return;

}

short print(struct terminal* t, char* string) {
    short count = 0;
    while(*string) {
        putchar(t, *string);
        string++;
        count++;
    };
    return count;
}

// such a stressful function to figure out... recursion saves the day.
// pass a number and do some math to disregard needing a len variable passed.
// adding to + '0' gets the ascii val of the exact number that needs to be printed
// inherently casting it to a character
// probably have some unneeded code in this but will update later 
// FIXME: clean up useless code
void print_num(struct terminal * t, short num) {
    char normal_num = num + '0';

    if (num >= 10) {
        short new_num = num / 10;
        if (new_num >= 10) {
            print_num(t, new_num);
        } else {
            char normal_num = new_num + '0';
            putchar(t,normal_num);
        }
        short remainder = num % 10;
        char remainder_print = remainder + '0';
        putchar(t, remainder_print);
    } else {
        putchar(t, normal_num);
        return;
    }
    return;
}

//FIXME: currently calling set_cursor 2000 times with this implementation, need to fix.
void clear_screen(struct terminal * t) {
    int i = 0;
    while(i < 2000) {
        putchar(t, ' ');
        i++;
    }
    return;
}

void set_cursor(unsigned short pos) {
    outb(0x3D4, 0x0F);
    outb(0x3D5, (unsigned char)(pos & 0xFF)); //zero out the high bits (like using al in eax)

    outb(0x3D4, 0x0E);
    outb(0x3D5, (unsigned char)(pos >> 8) & 0xFF); //shift high bits down to low bits and make sure we only send 8 bits
}