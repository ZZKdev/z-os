; naskfunc
; TAB=4

[FORMAT "WCOFF"]    ;制作目标文件的模式
[INSTRSET "i486"]
[BITS 32]           ;制作32位模式用的机器语言

;制作目标文件的信息
[FILE "naskfunc.s"] ;源文件名
    GLOBAL _io_hlt, _io_cli, _io_sti, _io_stihlt  ;程序中包含的函数名
    GLOBAL _io_in8, _io_in16, _io_in32
    GLOBAL _io_out8, _io_out16, _io_out32
    GLOBAL _io_load_eflags, _io_store_eflags
;以下是实际函数
[SECTION .text] ;目标文件写了这些后再写程序

_io_hlt:    ; void io_hlt(void);
        HLT
        ret

_io_cli:    ; void io_cli(void);
        CLI
        RET

_io_sti:    ; void io_sti(void);
        STI 
        RET

_io_stihlt:     ; void io_stihlt(void);
        STI
        HLT
        RET

_io_in8:        ; int io_in8(int port);
        mov edx, [esp+4]
        mov eax, 0
        in  al,  dx
        ret

_io_in16:       ; int io_in16(int port);
        mov edx, [esp+4]
        mov eax, 0
        in  ax,  dx
        ret

_io_in32:       ; int io_in32(int port);
        mov edx, [esp+4]
        in  eax, dx
        ret

_io_out8:       ; void io_out8(int port, int data);
        mov edx, [esp+4]
        mov al,  [esp+8]
        out dx,  al
        ret

_io_out16:      ; void io_out16(int port, int data);
        mov edx, [esp+4]
        mov eax, [esp+8]
        out dx,  ax
        ret

_io_out32:      ; void io_out32(int port, int data);
        mov edx, [esp+4]
        mov eax, [esp+8]
        out dx,  eax
        ret

_io_load_eflags:    ; int io_load_eflags(void);
        pushfd
        pop eax
        ret

_io_store_eflags:   ; void io_store_eflags(int eflags);
        mov eax, [esp+4]
        push eax
        popfd
        ret