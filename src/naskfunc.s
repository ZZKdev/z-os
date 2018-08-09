; naskfunc
; TAB=4

[FORMAT "WCOFF"]    ;制作目标文件的模式
[INSTRSET "i486"]
[BITS 32]           ;制作32位模式用的机器语言

;制作目标文件的信息
[FILE "naskfunc.s"] ;源文件名
    GLOBAL _io_hlt, _write_mem8  ;程序中包含的函数名

;以下是实际函数
[SECTION .text] ;目标文件写了这些后再写程序

_io_hlt:    ; void io_hlt(void);
        HLT
        ret

_write_mem8:    ; void write_mem8(int addr, int data);
        mov     ecx, [esp+4]
        mov     al,  [esp+8]
        mov     [ecx], al
        ret