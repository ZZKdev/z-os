#ifndef __ELF_H__
#define __ELF_H__

#include <stdint.h>

#define ELF_MAGICC 0x464c457fU

/* elf header */
struct elfhdr {
    uint32_t e_magic;
    uint8_t  e_elf[12];
    uint16_t e_type;            // 0 = none 1 = relocatable, 2 = executable, 3 = share object, 4 = core image
    uint16_t e_machine;         // 3 = Intel 80386
    uint32_t e_version;         // file version, alaways 1
    uint32_t e_entry;           // entry point if executable
    uint32_t e_phoff;           // file position of program header or 0
    uint32_t e_shoff;           // file position of section header or 0
    uint32_t e_flags;           // architecture-specific flags, usually 0
    uint16_t e_ehsize;          // size of this elf header
    uint16_t e_phentsize;       // size of an entry in program header or 0
    uint16_t e_phnum;           // number of entries in program header
    uint16_t e_shentsize;       // size of an entry in section header
    uint16_t e_shnum;           // number of entries in section header
    uint16_t e_shstrndx;        // section number that contains section name strings
};


/* program header */
struct porghdr {
    uint32_t p_type;            // 0 = null ignore,1 = loadable code, 2 = dynamic linking info
    uint32_t p_offset;          // file offset of segment
    uint32_t p_vaddr;           // virtual address to map segment
    uint32_t p_paddr;           // physical address, not used
    uint32_t p_filesz;          // size of segment in file
    uint32_t p_memsz;           // size of segment in memory (bigger if contains bss)
    uint32_t p_flags;           // read/write/execute bits, 1 = executable, 2 = read, 3 = write
    uint32_t p_align;           // required alignment, invariably hardware page size
};

#endif
