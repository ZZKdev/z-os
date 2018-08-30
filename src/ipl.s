;TAB=4
cyls equ 10			;要读入的柱面数

	ORG		0x7c00	;指明程序装载地址

;以下这段是标准FAT12格式软盘专用的代码
	jmp	entry
	nop				;内存对齐
	DB	"HELLOIPL"	;启动区的名称可以是任意的字符串（8字节）
	DW	512		;每个扇区的字节数。基本输入输出系统参数块从这里开始。 
	DB	1		;每簇扇区数
	DW	1		;保留扇区数（包括启动扇区） 
	DB	2		;文件分配表数目 
	DW	224		;最大根目录条目个数 
	DW	2880		;总扇区数（如果是0，就使用偏移0x20处的4字节值）
	DB	0xf0		;磁盘的种类（必须是0xf0）
	DW	9		;每个文件分配表的扇区数（FAT16） 
	DW	18		;1个磁道（track）有几个扇区（必须是18）
	DW	2		;磁头数（必须是2）
	DD	0		;隐藏扇区
	DD 	2880		;重写一次磁盘大小
	DB	0, 0, 0x29	;意义不明，固定
	DD	0xffffffff	;（可能是）卷标号码
	DB	"HELLO-OS   "	;磁盘名称（11字节）
	DB	"FAT12   "	;磁盘格式名称（8字节）
	RESB	18		;先空出18字节

;程序主体

entry:
	mov	ax, 0	;初始化寄存器
	mov ss, ax
	mov sp, 0x7c00
	mov ds, ax

;读取磁盘
	mov ax, 0x0820
	mov es, ax
	mov ch, 0	;柱面0
	mov dh, 0	;磁头0
	mov cl, 2	;扇区2

readloop:
	mov si, 0	;记录失败次数寄存器

retry:
	mov ah, 0x02	;ah=0x02 : 读入磁盘
	mov al, 1		;		
	mov bx, 0
	mov dl, 0x00	;A驱动器
	int 0x13		;调用磁盘BIOS
	jnc	next		;没出错就跳转到fin
	add si, 1		;往si加1
	cmp	si, 5		;比较si与5
	jae error		;si >= 5 跳转到error
	mov	ah, 0x00
	mov dl, 0x00	;A驱动器
	int 0x13		;重置驱动器
	jmp	retry

next: 
	mov ax, es		;把内存地址往后移0x200(512/16十六进制转换)
	add ax, 0x0020	
	mov es, ax		;add es, 0x020因为没有add es, 只能通过ax进行
	add cl, 1
	cmp cl, 18
	jbe	readloop	; cl <= 18 跳转到readloop
	mov cl, 1
	add dh, 1
	cmp dh, 2
	jb readloop		; dh < 2 跳转到readloop
	mov dh, 0
	add ch, 1
	cmp ch, cyls
	jb readloop		; ch < cyls 跳转到readloop

; 跳转到os
	mov [0x0ff0], ch	;记录读取的柱面数
	jmp 0xc200



error:
	mov si, msg

putloop:
	mov	al, [si]
	add si, 1
	cmp al, 0
	je 	fin
	mov ah, 0x0e	;显示一个文字
	mov bx, 15		;指定字符颜色
	int 0x10		;调用显卡bios
	jmp	putloop

fin:
	hlt				;让CPU待机，等待指令
	jmp	fin			;无限循环

msg:
	db	0x0a, 0x0a
	db 	"load error"
	db	0x0a
	db 	0

	resb 0x7dfe-$	;填写0x00直到0x001fe
	db 0x55, 0xaa
