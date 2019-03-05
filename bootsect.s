.include "boot.inc"
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
    movb $'d', %gs:1900
    movb $0xb4, %gs:1901   

load_setup:
    mov $LOADER_START_SECTOR, %eax
    mov $LOADER_BASE_ADDR, %dx
    mov %dx, %ds
    mov $0, %bx
    mov $4, %cx
    call read_disk_16
    ljmp $LOADER_BASE_ADDR, $0

    
#------------------------------------------------------------------------------------------------
# 从硬盘读取n个扇区
# eax = LBA 扇区号
# ds:bx  = 将数据写入的内存地址
# cx  = 读入的扇区数
#------------------------------------------------------------------------------------------------
read_disk_16:

    mov %cx, %di
    # 设置要读取的LBA起始地址
    mov $0x1f3, %dx
    out %al, %dx            # 0-7 位LBA地址
    mov $8, %cl             # 设置右移位数

    shr %cl, %eax
    mov $0x1f4, %dx
    out %al, %dx            # 8-15 位LBA地址
    
    shr %cl, %eax
    mov $0x1f5, %dx
    out %al, %dx            # 16-23 位LBA地址
    
    shr %cl, %eax           # 低4位为 24-27 位LBA地址
    and $0x0f, %al          # 高4位置0
    or  $0xe0, %al          # 高4位置为1110, LBA寻址模式, 主盘
    mov $0x1f6, %dx
    out %al, %dx            # device 寄存器
    # 设置要读取的扇区数
    mov %di, %ax
    mov $0x1f2, %dx
    out %al, %dx

    # 往 command 寄存器发送读命令
    mov $0x20, %al
    mov $0x1f7, %dx
    out %al, %dx

# 检测硬盘状态
    mov $0x1f7, %dx
not_ready:
    nop                     # 不操作延迟一下
    in  %dx, %al
    and $0x88, %al          # 保留第3和第7位分别是DRQ位(表示硬盘是否准备好数据), BSY位(表示硬盘是否正忙)
    cmp $0x08, %al          # 检查DRQ位是否为1, BSY位为0, 不是的话继续检测
    jnz not_ready

# 从0x1f0中读取数据
    mov %di, %ax
    mov $256, %dx
    mul %dx
    mov %ax, %cx
    mov $0x1f0, %dx
read_next:
    in  %dx, %ax
    mov %ax, (%bx)
    add $2, %bx
    loop read_next    
    ret
#------------------------------------------------------------------------------------------------


.=0x1fe                 # 用0填充字节到0x1fe位置 
boot_flag:
    .word 0xaa55
