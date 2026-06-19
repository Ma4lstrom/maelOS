#include "print.h"
#include "types.h"

struct __attribute__((packed)) idt_entry {
    uint16_t offset_low;
    uint16_t selector;
    uint8_t null_byte;
    uint8_t attribute;
    uint16_t offset_high;
};

void fill_idt(struct idt_entry *idt);



void kmain(void) {
    struct terminal t;
    t.x = 0;
    t.y = 0;
    t.buffer = (short *)0xB8000;
    t.color = (short)0x0F;
    struct idt_entry idt[256] = {0};
    fill_idt(idt);
    clear_screen(&t);
    // short count_written = print(&t, "Hello Kern!\n");
    // print_num(&t, count_written);
    print(&t, "Hello From MaelOS!\n");
    // for (short i = 0; i < 5; i++) {
    //    print(&t, "offset_low: ");
    //    print_num(&t, (uint16_t)idt[i].offset_low);
    //    print(&t, "\n");

    //    print(&t, "selector: ");
    //    print_num(&t, (uint16_t)idt[i].selector);
    //    print(&t, "\n");

    //    print(&t, "attribute: ");
    //    print_num(&t, (uint16_t)idt[i].attribute);
    //    print(&t, "\n");

    //    print(&t, "offset_high: ");
    //    print_num(&t, (uint16_t)idt[i].offset_high);
    //    print(&t, "\n");
    //    print(&t, "\n");
    // }
    


    while (1) {
        __asm__ volatile("hlt");
    }
}

static inline void isr_default() {
    __asm__ volatile (
        "cli\n"
        "hlt\n"
    ); 
}

void fill_idt(struct idt_entry *idt) {
    for (int i = 0; i < 256; i++) {
        idt[i].offset_low = (uint16_t)((uint32_t)isr_default & 0xFFFF);
        idt[i].selector = 0x08;
        idt[i].null_byte = 0;
        idt[i].attribute = 0x8E;
        idt[i].offset_high = (uint16_t)((uint32_t)isr_default >> 16);
    };

     __asm__ volatile (
        "lidt %0"
        :
        : "m"(idt)
    ); 
    return;
}