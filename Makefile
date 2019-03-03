AS=as
OBJCOPY=objcopy
QEMU=qemu-system-i386
BOCHS=bochs



bootsect.o: bootsect.s
	$(AS) --32 -o bootsect.o bootsect.s
	$(OBJCOPY) -j .text -O binary bootsect.o

kernel.img: bootsect.o
	bximage -hd=60M -mode=create -q kernel.img 
	dd if=bootsect.o of=kernel.img bs=512 count=1 conv=notrunc

run: kernel.img
	$(QEMU) -boot c -hda kernel.img

clean: 
	@rm *.o *.img *.out


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
