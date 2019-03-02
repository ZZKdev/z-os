.code16
.equ BOOTSEG, 0x07c0

# 设置cs:ip指针
ljmp $BOOTSEG, $_start

_start:
    mov $0xb800, %ax
    mov %ax, %gs
    movb $'H', %gs:0
    movb $0xa4, %gs:1   
    movb $'e', %gs:2
    movb $0xa4, %gs:3   
    movb $'l', %gs:4
    movb $0xa4, %gs:5   
    movb $'l', %gs:6
    movb $0xa4, %gs:7   
    movb $'o', %gs:8
    movb $0xa4, %gs:9   
    movb $' ', %gs:10
    movb $0xa4, %gs:11   
    movb $'w', %gs:12
    movb $0xa4, %gs:13   
    movb $'o', %gs:14
    movb $0xa4, %gs:15   
    movb $'r', %gs:16
    movb $0xa4, %gs:17   
    movb $'l', %gs:18
    movb $0xa4, %gs:19   
    movb $'d', %gs:20
    movb $0xa4, %gs:21   

forerver:
    hlt


.=0x1fe                 # 用0填充字节到0x1fe位置 
boot_flag:
    .word 0xaa55
