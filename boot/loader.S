#include "boot.h"
.include "boot.inc"
.code16
.equ LOADER_STACK_TOP, LOADER_BASE_ADDR
jmp go_protect
#--------------------------------------------------------------------------------------------
# 构建 gdt 描述符
#--------------------------------------------------------------------------------------------
GDT_BASE: 
    SEGMENT_NULL
GDT_DES:
    SEGMENT_DEFINE(SEG_X, 0, 0xffffffff)
DATA_STACK_DESC: 
    SEGMENT_DEFINE(SEG_W, 0, 0xffffffff)
VIDEO_DESC:
    SEGMENT_DEFINE(SEG_W, 0xb8000, 0x7fff)

.equ GDT_SIZE, .-GDT_BASE
.equ GDT_LIMIT, GDT_SIZE-1

# 预留的段描述符
.rept 60 .quad 0
.endr



# 定义段选择子
.equ SELECTOR_CODE, (0x0001 << 3) + TI_GDT + RPL0
.equ SELECTOR_DATA, (0x0002 << 3) + TI_GDT + RPL0
.equ SELECTOR_VIDEO,(0x0003 << 3) + TI_GDT + RPL0

# gdtr寄存器值
gdt_ptr:
    .word GDT_LIMIT
    .long GDT_BASE + LOADER_BASE_ADDR << 4

#--------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------------
# 检测内存大小
#--------------------------------------------------------------------------------------------
# memory_data:
# .rept 60 .quad 0
# .endr
# 
# detect_memory:
#     xor %ebx, %ebx
#     mov $LOADER_BASE_ADDR, %ax
#     mov %ax, %es
#     mov $memory_data, %di
#     mov $0x534d4150, %edx
#     next:
#         mov $20, %ecx
#         mov $0xe820, %eax
#         int $0x15
#         add %cx, %di
#         cmp $0, %ebx
#         jz go_protect
#         jmp next
# #--------------------------------------------------------------------------------------------



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

    # 远跳转刷新流水线
    ljmp $SELECTOR_CODE, $p_mode_start + LOADER_BASE_ADDR << 4
#--------------------------------------------------------------------------------------------

.code32
#--------------------------------------------------------------------------------------------
# 初始化保护模式下的段寄存器
#--------------------------------------------------------------------------------------------
p_mode_start:
    mov $SELECTOR_DATA, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %ss
    mov $LOADER_STACK_TOP << 4, %esp
    mov $SELECTOR_VIDEO, %ax
    mov %ax, %gs
    movb $'1', %gs:0
    movb $0xa4, %gs:1
#--------------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------------
# 读取内核
#--------------------------------------------------------------------------------------------
     mov $KERNEL_START_SECTOR, %eax
     mov $KERNEL_BIN_BASE_ADDR, %ebx
     mov $200, %ecx
     call read_disk_32
#--------------------------------------------------------------------------------------------




#--------------------------------------------------------------------------------------------
# 设置页表
#--------------------------------------------------------------------------------------------
    call setup_page
    # 保存gdtr寄存器的值
    sgdt gdt_ptr + LOADER_BASE_ADDR << 4
    
    # 给显存描述符的段基址移动动高3G的内存那里去
    movl gdt_ptr + LOADER_BASE_ADDR << 4 + 2, %ebx
    addl $0xc0000000, 8 * 3 + 4(%ebx) 

    # 段描述符都给移动到高3G的内核地址空间去
    addl $0xc0000000, gdt_ptr + LOADER_BASE_ADDR << 4 + 2
    
    # 栈指针也移动内核空间那里去
    add $0xc0000000, %esp

    # 设置页目录地址给cr3寄存器
    mov $PAGE_DIR_TABLE_POS, %eax
    mov %eax, %cr3

    # 设置CR0寄存器的PG位(第31位)
    mov %cr0, %eax
    or $0x80000000, %eax
    mov %eax, %cr0

    # 重新加载段寄存器
    lgdt gdt_ptr + LOADER_BASE_ADDR << 4
    # 验证一下随便打点东西
    movb $'z', %gs:0
#--------------------------------------------------------------------------------------------
    



#--------------------------------------------------------------------------------------------
# 进入内核开始工作
#--------------------------------------------------------------------------------------------
enter_kernel:
    call kernel_init
    mov $KERNEL_ENTRY_POINT, %esp
    mov $0xc0001500, %eax
    jmp *%eax
    jmp .
    jmp .
#--------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------------
# function 
# 设置页表
#--------------------------------------------------------------------------------------------
setup_page:
    mov $4096, %ecx
    mov $0, %esi
# 把页目录的空间置0
clear_page_dir:
    movb $0, PAGE_DIR_TABLE_POS(%esi) 
    inc %esi
    loop clear_page_dir
# 创建页目录项
create_pde:
    mov $PAGE_DIR_TABLE_POS, %eax
    add $4096, %eax                             # 第一个页表的地址紧邻在页目录后面
    add $PG_P + PG_RW_W + PG_US_U, %eax 

    mov %eax, PAGE_DIR_TABLE_POS                # 这里设置了第0和第768个页表项它们都指向了相同的页表
    mov %eax, PAGE_DIR_TABLE_POS + 768 * 4      

    sub $4096, %eax
    mov %eax, PAGE_DIR_TABLE_POS + 1023 * 4     # 设置第1023个页目录项,指向页目录表自己的地址

# 创建低端1M内存的页表项
    mov $256, %ecx
    mov $0, %esi
    mov $PG_P + PG_RW_W + PG_US_U, %edx
    mov $PAGE_DIR_TABLE_POS + 4096, %ebx
create_pte:
    mov %edx, (%ebx, %esi, 4)
    add $4096, %edx
    inc %esi
    loop create_pte    

# 创建内核的其他页表的PDE
    mov $PAGE_DIR_TABLE_POS + 4096 * 2 + PG_P + PG_RW_W + PG_US_U, %eax
    mov $PAGE_DIR_TABLE_POS, %ebx
    mov $254, %ecx
    mov $769, %esi
create_kernel_pde:
    mov %eax, (%ebx, %esi, 4)
    inc %esi
    add $4096, %eax
    loop create_kernel_pde
    ret
#--------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------------
# function
# 内核初始化, 将elf格式的内核解析后放到合适位置 
#--------------------------------------------------------------------------------------------
kernel_init:
    xor %eax, %eax
    xor %ebx, %ebx                              # 记录程序头表地址
    xor %ecx, %ecx                              # 记录 program header 数量
    xor %edx, %edx                              # 记录一个 program header 的大小
    mov KERNEL_BIN_BASE_ADDR + 42, %dx          # e_phentsize program header 条目大小

    mov KERNEL_BIN_BASE_ADDR + 28, %ebx         # e_phoff     program header 在文件中的偏移量
    add $KERNEL_BIN_BASE_ADDR, %ebx

    mov KERNEL_BIN_BASE_ADDR + 44, %cx          # e_phnum     program header 的数量
# 遍历每一个program header
each_segment:
    cmpb $PT_NULL, (%ebx)
    je PTNULL
    
    pushl 16(%ebx)                              # p_filesz    段的大小
    
    mov 4(%ebx), %eax                           # p_offset    段的偏移
    add $KERNEL_BIN_BASE_ADDR, %eax                    
    push %eax
    
    pushl 8(%ebx)                               # p_vaddr     段要加载到的虚拟地址
    call mem_cpy
    add $12, %esp
PTNULL:
    add %edx, %ebx
    loop each_segment
    ret
    
# 三个参数 dst, src, size 从右到左入栈
mem_cpy:
    cld
    push %ebp
    mov %esp, %ebp
    push %ecx
    
    mov 8(%ebp), %edi   # dst
    mov 12(%ebp), %esi  # src
    mov 16(%ebp), %ecx  # size
    rep movsb
    
    pop %ecx
    pop %ebp
    ret
#--------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------------
# function
# 从硬盘读取n个扇区
# eax = LBA 扇区号
# ds:ebx = 将数据写入的内存地址
# cx = 读入的扇区数
#--------------------------------------------------------------------------------------------
read_disk_32:
    mov %cx, %di
    # 设置要读取的LBA起始地址
    mov $0x1f3, %dx         # 0 - 7 位LBA地址
    out %al, %dx
    
    mov $8, %cx
    shr %cl, %eax
    mov $0x1f4, %dx         # 8 - 15 位LBA地址
    out %al, %dx
    
    shr %cl, %eax
    mov $0x1f5, %dx
    out %al, %dx            # 16 - 23 位LBA地址
    
    shr %cl, %eax           # 低4位为 24 - 27 位LBA地址
    and $0x0f, %al          # 高4位置0
    or  $0xe0, %al          # 高4为置为 1110, LBA寻址模式, 主盘
    mov $0x1f6, %dx
    out %al, %dx            # device 寄存器
    
    # 设置要读取的扇区数
    mov %di, %ax
    mov $0x1f2, %dx
    out %al, %dx
    
    # 往 command 寄存器发送命令
    mov $0x20, %al
    mov $0x1f7, %dx
    out %al, %dx

    # 检测硬盘状态
    mov $0x1f7, %dx
not_ready:
    nop                     # 不操作延迟一下
    in %dx, %al
    and $0x88, %al          # 保留第3和7位, DRQ位(硬盘是否准备号数据), BSY位(硬盘是否正忙)
    cmp $0x08, %al          # 检查DRQ位是否为1, BSY位是否为0
    jnz not_ready
   
    # 从0x1f0 中读数据
    mov %di, %ax
    mov $256, %dx
    mul %dx
    mov %ax, %cx
    mov $0x1f0, %dx
read_next:
    in %dx, %ax
    mov %ax, (%ebx)
    add $2, %ebx
    loop read_next
    ret
    
#--------------------------------------------------------------------------------------------
