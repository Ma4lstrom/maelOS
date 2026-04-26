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

short print(struct terminal *t, char* string);

void print_num(struct terminal *t, short num);

void clear_screen(struct terminal *t);

#endif