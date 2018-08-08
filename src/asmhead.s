; os
; TAB=4

botpak  equ     0x00280000  ;加载bootpack
dskcac  equ     0x00100000  ;磁盘缓存位置
dskcac0 equ     0x00008000  ;磁盘的缓存模式（实模式）    

;有关BOOT_INFO
cyls    equ     0x0ff0  ;设定启动区
leds    equ     0x0ff1
vmode   equ     0x0ff2  ;关于颜色数目的信息。颜色的位数
scrnx   equ     0x0ff4  ;分辨率的x
scrny   equ     0x0ff6  ;分辨率的y
vram    equ     0x0ff8  ;图像缓冲区的地址  

ORG     0xc200
;设置屏幕模式
mov     al, 0x13        ;VGA显卡，320*200*8位彩色
mov     ah, 0x00
int     0x10
mov     byte [vmode], 8     ;记录画面模式
mov     word [scrnx], 320
mov     word [scrny], 200
mov     dword [vram], 0x000a0000

;用bios取得键盘上各种led灯的指示状态
mov     ah, 0x02
int     0x16        ;keyborad bios
mov     [leds], al


;防止pic接受所有中断
;AT兼容机的规范、pic的初始化
;然后之前再CLI不做任何事就挂起
;pic再同意后初始化

    mov al, 0xff
    out 0x21, al
    nop             ;不断执行out指令
    out 0xa1, al
    cli
;让cpu支持1M以上的内存、设置A20GATE
    call waitkbdout
    mov  al, 0xd1
    out  0x64, al
    call waitkbdout
    mov  al, 0xdf
    out  0x60, al
    call waitkbdout

;保护模式转换
    [instrest "i486p"]  ;说明使用486指令
    lgdt [gdtr0]        ;设置临时GDT
    mov  eax, cr0
    and  eax, 0x7fffffff;使用bit31（禁用分页）
    or   eax, 0x00000001;bit0到1转换（保护模式过渡）
    mov  cr0, eax
    jmp  pipelineflush

pipelineflush:
    mov ax, 1*8         ;写32bit的段
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
;bootpack 传递
    mov esi, bootpack   ;源
    mov edi, botpak     ;目标
    mov ecx, 512*1024/4
    call memcpy
;传输磁盘数据
;从引导区开始
    mov esi, 0x7c00     ;源
    mov edi, dskcac     ;目标
    mov ecx, 512/4
    call memcpy
;剩余的全部
    mov  esi, dskcac0+512    ;源
    mov  edi, dskcac+512     ;目标
    mov  ecx, 0
    mov  cl, byte [cyls]
    imul ecx, 512*18*2/4    ;除以4得到字节数
    sub  ecx, 512/4         ;ipl偏移量
    call memcpy
;由于还需要asmhead才能完成
;完成其余的bootpack任务

;bootpack启动
    mov  ebx, botpak
    mov  ecx, [ebx+16]
    add  ecx, 3
    shr  ecx, 2
    jz   skip            ;传输完成
    mov  esi, [ebx+20]   ;源
    add  esi, ebx
    mov  edi, [ebx+12]   ;目标
    call memcpy

skip:
    mov esp, [ebx+12]   ;堆栈初始化
    jmp dword 2*8:0x0000001b

waitkbdout:
    in  al, 0x64
    and al, 0x02
    jnz waitkbdout
    ret

memcpy:
    mov eax, [esi]
    add esi, 4
    mov [edi], eax
    add edi, 4
    sub ecx, 1
    jnz memcpy
    ret
;memcpy地址前缀大小
    alignb 16

gdt0:
    resb 8      ;初始值
    dw   0xffff, 0x0000, 0x9200, 0x00cf ;写32bit位寄存器
    dw   0xffff, 0x0000, 0x9a28, 0x0047 ;可执行文件的32bit寄存器
    dw   0
gdtr0:
    dw     8*3-1
    dd     gdt0
    alignb 16
bootpack: