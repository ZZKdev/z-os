# 计算机引导过程

## 从BIOS到0x7c00
计算机启动时,在CPU会预先设好下面寄存器的值
```
cs 0xf000
ip 0xfff0
```
经过计算得到的物理地址为(0xf000 << 4 + 0xfff0) = 0xffff0.

根据实模式下的内存布局, 我们可以了解到这里存放着跳进BIOS的指令, 从这里开始BIOS程序就开始运行了

现在BIOS程序进行硬件自检并在内存中加载中断向量表和中断服务程序。检测可引导的设备，将引导扇区的512个字节加载到内存上的0x7c00地址处。将控制权交到下一阶段的启动程序，通过`jmp 0: 0x7c00` 跳转到 0x7c00处.

> 通过查看设备第一个扇区的最后两个字节是否0x55aa来判断是否可以引导

> cpu会执行cs:ip寄存器指向的程序代码

通过上面的介绍我们可以编写一个最简易引导扇区
```
; bootsect.s
.code16
.= 510              ;用0填充字节到第520个字节的位置
.word 0xaa55        ;定义标识符


; Makefile
bootsect: bootsect.s
    as --32 -o bootsect.o bootsect.s
    objcopy -O binary -j .text bootsect.o -o bootsect
run: bootsect
    qemu-system-i386 -boot a -fda bootsect
```



推荐阅读 : [实模式内存布局](实模式内存布局.md)

