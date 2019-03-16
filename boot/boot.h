#ifndef __BOOT_H__
#define __BOOT_H__

// 空的段描述符
#define SEGMENT_NULL                \
    .long 0x0000000;            \
    .long 0x0000000
#define SEGMENT_DEFINE(type, base, limit)       \
    .word (((limit) >> 12) & 0xffff), ((base) & 0xffff);    \
    .byte (((base) >> 16) & 0xff), (0x90 | (type)),         \
        (0xc0 | (((limit) >> 28) & 0xf)), (((base) >> 24) & 0xff)

// 段描述符的类型
#define SEG_X       0x8     //
#define SEG_E       0x4     //
#define SEG_C       0x4     //
#define SEG_W       0x2     //
#define SEG_R       0x2     //
#define SEG_A       0x1     //


// loader 和 kernel
#define LOADER_START_SECTOR 0x2
#define LOADER_BASE_ADDR    0x90
#endif
