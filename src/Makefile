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

os.bin : os.s Makefile
	$(NASK) os.s os.bin os.lst

os.img : ipl.bin os.bin Makefile
	$(EDIMG) imgin:../z_tools/fdimg0at.tek wbinimg src:ipl.bin len:512 from:0 to:0 copy from:os.bin to:@: imgout:os.img

# 其他指令

img : 
	$(MAKE) -r os.img

run :
	$(MAKE) img
	$(COPY) os.img ..\z_tools\qemu\fdimage0.bin
	$(MAKE) -C ../z_tools/qemu

clean :
	-$(DEL) ipl.bin
	-$(DEL) ipl.lst
	-$(DEL) os.bin
	-$(DEL) os.lst

src_only :
	$(MAKE) clean
	-$(DEL) os.img