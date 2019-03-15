#ifndef __BOOT_H__
#define __BOOT_H__

#define SEG_NULL                \
    .long 0x0000000;            \
    .long 0x0000000


#define LOADER_START_SECTOR 0x2
#define LOADER_BASE_ADDR    0x90
#endif
