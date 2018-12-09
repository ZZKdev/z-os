.code16
.equ BOOTSEG, 0x07c0

# 设置cs:ip指针
ljmp $BOOTSEG, $_start

_start:
    # https://zh.wikipedia.org/wiki/INT_10H 查看中断
    mov $BOOTSEG, %ax
    mov %ax, %es        # 将es:bp指向要打印的字符串
    mov $_msg, %bp

    mov $0x03, %ah      # 获取行和列到DH和DL寄存器
    int $0x10

    mov $0x0e, %cx      # 设置要打印的字符个数
    mov $0x00, %bh      # 设置页码
    mov $0x0e, %bl      # 设置字符颜色和背景　黑色背景黄色字体
    mov $0x01, %al      # 设置显示模式　0x01 40*25 16色文本
    mov $0x13, %ah      # 设置写字符串的模式
    int $0x10
forerver:
    hlt

_msg: 
    .ascii "hello world!\r\n"
    

.=0x1fe                 # 用0填充字节到0x1fe位置 
boot_flag:
    .word 0xaa55
