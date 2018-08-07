;hello-os
;TAB=4

	ORG		0x7c00	;指明程序装载地址

;以下这段是标准FAT12格式软盘专用的代码
	jmp	entry
	DB	0xeb, 0x4e, 0x90
	DB	"HELLOIPL"	;启动区的名称可以是任意的字符串（8字节）
	DW	512		;每个扇区（sector）的大小（必须为512字节）
	DB	1		;簇（cluster)的大小（必须为1个扇区）
	DW	1		;FAT的起始位置（一般从第一个扇区开始）
	DB	2		;FAT的个数（必须为2）
	DW	224		;根目录的大小（一般设成224项）
	DW	2880		;该磁盘的大小（必须是2880扇区）
	DB	0xf0		;磁盘的种类（必须是0xf0）
	DW	9		;FAT的长度（必须是9扇区）
	DW	18		;1个磁道（track）有几个扇区（必须是18）
	DW	2		;磁头数（必须是2）
	DD	0		;不使用分区，必须是0
	DD 	2880		;重写一次磁盘大小
	DB	0, 0, 0x29	;意义不明，固定
	DD	0xffffffff	;（可能是）卷标号码
	DB	"HELLO-OS   "	;磁盘名称（11字节）
	DB	"FAT12   "	;磁盘格式名称（8字节）
	RESB	18		;先空出18字节

;程序主体

entry:
	mov	ax, 0
	mov ss, ax
	mov	sp, 0x7c00
	mov	ds, ax
	mov es, ax
	mov si, msg

putloop:
	mov	al, [si]
	add	si, 1
	cmp	al, 0
	je	fin
	mov	ah, 0x0e
	mov	bx, 15
	int	0x10
	jmp putloop

fin:
	HLT
	jmp fin

; 信息显示部分

msg:
	DB	0x0a, 0x0a			; 换行两次
	DB	"hello, world"
	DB	0x0a				; 换行
	DB	0
	RESB	0x7dfe-$		; 填写0x00直到0x001fe
	DB	0x55, 0xaa