#ifndef PRINT_H
#define PRINT_H

#define VGA_WIDTH 80
#define VGA_HEIGHT 25
struct terminal {
    short x;
    short y;
    short * buffer; //0xB8000
    short color;
};

void putchar(struct terminal* t, char c);

void set_cursor(unsigned short pos);

void print(char* string);

void clear_screen();

#endif