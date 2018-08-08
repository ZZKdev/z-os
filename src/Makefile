TOOLPATH = ../z_tools/
MAKE 	 = $(TOOLPATH)make.exe -r
NASK 	 = $(TOOLPATH)nask.exe
EDIMG	 = $(TOOLPATH)edimg.exe
COPY	 = copy
DEL		 = del

# 默认动作
default :
	$(MAKE) img

# 镜像文件生成

ipl.bin : ipl.s Makefile
	$(NASK) ipl.s ipl.bin ipl.lst

helloos.img : ipl.bin Makefile
	$(EDIMG) imgin:../z_tools/fdimg0at.tek wbinimg src:ipl.bin len:512 from:0 to:0 imgout:helloos.img

# 其他指令

asm : 
	$(MAKE) -r ipl.bin

img : 
	$(MAKE) -r helloos.img

run :
	$(MAKE) img
	$(COPY) helloos.img ..\z_tools\qemu\fdimage0.bin
	$(MAKE) -C ../z_tools/qemu

clean :
	-$(DEL) ipl.bin
	-$(DEL) ipl.lst

src_only :
	$(MAKE) clean
	-$(DEL) helloos.img