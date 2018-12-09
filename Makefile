AS=as
OBJCOPY=objcopy
QEMU=qemu-system-i386



bootsect.o: bootsect.s
	$(AS) --32 -o bootsect.o bootsect.s
	$(OBJCOPY) -j .text -O binary bootsect.o

run: bootsect.o
	$(QEMU) -boot a -fda bootsect.o

clean: 
	@rm *.o
