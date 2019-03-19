#define outb(port, value) \
    __asm__ volatile("outb %%al, %%dx"::"a"(value), "d"(value));
#define inb(port) ({\
    unsigned char _v;\
    __asm__ volatile("inb %%dx, %%al":"=a"(_v):"d"(port));\
    _v;\
    })
