AS=as
OBJCOPY=objcopy
QEMU=qemu-system-i386
BOCHS=bochs



bootsect.o: bootsect.s
	$(AS) --32 -o bootsect.o bootsect.s
	$(OBJCOPY) -j .text -O binary bootsect.o

loader.o: loader.s
	$(AS) --32 loader.s -o loader.o
	$(OBJCOPY) -j .text -O binary loader.o

kernel.img: bootsect.o loader.o
	bximage -hd=60M -mode=create -q kernel.img 
	dd if=bootsect.o of=kernel.img bs=512 count=1 conv=notrunc
	dd if=loader.o of=kernel.img bs=512 count=20 conv=notrunc seek=2

run: kernel.img
	$(QEMU) -boot c -hda kernel.img

clean: 
	-@rm *.o *.img *.out 2>/dev/null


# bochs
bochs-run: kernel.img
	bochs -f bochsrc



# docker
gen-docker: Dockerfile
	docker build -t osdocker .

docker-make: 
	docker run \
		--rm \
		--volume $(PWD):/home/ \
		osdocker \
		make kernel.img -C /home/

docker-run:
	docker run \
		--rm \
		-it \
		--volume $(PWD):/home/ \
		osdocker \
		$(QEMU) -boot c -hda /home/kernel.img -display curses 
