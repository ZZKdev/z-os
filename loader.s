.include "boot.inc"
.code16
.equ LOADER_STACK_TOP, LOADER_BASE_ADDR
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

    ljmp $SELECTOR_CODE, $p_mode_start + LOADER_BASE_ADDR << 4
#--------------------------------------------------------------------------------------------

.code32
p_mode_start:
    mov $SELECTOR_DATA, %ax
    mov %ax, %ds
    mov %ax, %ss
    mov $LOADER_STACK_TOP << 4, %esp
    mov $SELECTOR_VIDEO, %ax
    mov %ax, %gs
    movb $'1', %gs:0
    movb $0xa4, %gs:1


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
    jmp .


# function 设置页表
# 把页目录的空间置0
setup_page:
    mov $4096, %ecx
    mov $0, %esi
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
