; os
; TAB=4
    ;有关BOOT_INFO
    cyls    equ     0x0ff0  ;设定启动区
    leds    equ     0x0ff1
    vmode   equ     0x0ff2  ;关于颜色数目的信息。颜色的位数
    scrnx   equ     0x0ff4  ;分辨率的x
    scrny   equ     0x0ff6  ;分辨率的y
    vram    equ     0x0ff8  ;图像缓冲区的地址  

    ORG     0xc200

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

 
    
fin:
    hlt
    jmp fin