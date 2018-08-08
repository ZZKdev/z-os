TOOLPATH = ../z_tools/
INCPATH  = ../z_tools/haribote/

MAKE 	 = $(TOOLPATH)make.exe -r
NASK 	 = $(TOOLPATH)nask.exe
EDIMG	 = $(TOOLPATH)edimg.exe
CC1		 = $(TOOLPATH)ccl.exe -I$(INCPATH) -Os -Wall -quiet
GAS2NASK = $(TOOLPATH)gas2nask.exe -a
OBJ2BIM  = $(TOOLPAHT)obj2bim.exe
BIM2HRB	 = $(TOOLPATH)bim2hrb.exe
RULEFILE = $(TOOLPATH)haribote/haribote.rul
COPY	 = copy
DEL		 = del

# 默认动作
default :
	$(MAKE) img

# 镜像文件生成

ipl.bin : ipl.s Makefile
	$(NASK) ipl.s ipl.bin ipl.lst

asmhead.bin : asmhead.s  Makefile
	$(NASK) asmhead.s asmhead.bin asmhead.lst

bootpack.gas : bootpack.c Makefile
	$(CC1) -o bootpack.gas bootpack.c

bootpack.s : bootpack.gas Makefile
	$(GAS2NASK) bootpack.gas bootpack.s

bootpack.obj : bootpack.s Makefile
	$(NASK) bootpack.s bootpack.obj bootpack.lst

naskfunc.obj : naskfunc.s Makefile
	$(NASK) naskfunc.s naskfunc.obj naskfunc.lst

bootpack.bim : bootpack.obj naskfunc.obj Makefile
	$(OBJ2BIM) @$(RULEFILE) out:bootpack.bim stack:3136 map:bootpack.map bootpack.obj naskfunc.obj
# 3MB + 64kb = 3136kb

bootpack.hrb : bootpack.bim Makefile
	$(BIM2HRB) bootpack.bim bootpack.hrb 0

os.bin : asmhead.bin bootpack.hrb Makefile
	copy /B asmhead.bin+bootpack.hrb os.bin


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
	-$(DEL) *.bin
	-$(DEL) *.lst
	-$(DEL) *.gas
	-$(DEL) *.obj
	-$(DEL) bootpack.s
	-$(DEL) bootpack.map
	-$(DEL) bootpack.bim
	-$(DEL) bootpack.hrb
	-$(DEL) os.bin
src_only :
	$(MAKE) clean
	-$(DEL) os.img