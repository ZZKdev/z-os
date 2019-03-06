.include "boot.inc"
.code16
jmp go_protect
#--------------------------------------------------------------------------------------------
# 构建 gdt 描述符
#--------------------------------------------------------------------------------------------
GDT_BASE: 
    .long 0x00000000
    .long 0x00000000
GDT_DES:
    .long 0x0000FFFF
    .long DESC_CODE_HIGH4
DATA_STACK_DESC: 
    .long 0x0000FFFF
    .long DESC_DATA_HIGH4            
VIDEO_DESC:
    .long 0x80000007
    .long DESC_VIDEO_HIGH4

.equ GDT_SIZE, .-GDT_BASE
.equ GDT_LIMIT, GDT_SIZE-1
.rept 60 .quad 0
.endr



# 定义段选择子
.equ SELECTOR_CODE, (0x0001 << 3) + TI_GDT + RPL0
.equ SELECTOR_DATA, (0x0002 << 3) + TI_GDT + RPL0
.equ SELECTOR_VIDEO,(0x0003 << 3) + TI_GDT + RPL0

gdt_ptr:
    .word GDT_LIMIT
    .long GDT_BASE + LOADER_BASE_ADDR << 4

#--------------------------------------------------------------------------------------------



#--------------------------------------------------------------------------------------------
# 进入保护模式
#--------------------------------------------------------------------------------------------
go_protect:
    # 打开A20地址线
    mov $0x92, %dx
    in %dx, %al
    or $00000010, %al
    out %al, $0x92

    # 设置GDT表
    lgdt gdt_ptr
    # 将cr0寄存器pe位置为1
    mov %cr0, %eax
    or  $0x01, %eax
    mov %eax, %cr0

    ljmp $SELECTOR_CODE, $p_mode_start + LOADER_BASE_ADDR << 4
#--------------------------------------------------------------------------------------------

.code32
p_mode_start:
    mov $SELECTOR_VIDEO, %ax
    mov %ax, %gs
    movb $'1', %gs:0
    movb $0xa4, %gs:1
    jmp .
