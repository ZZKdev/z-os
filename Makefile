AS=as
OBJCOPY=objcopy
QEMU=qemu-system-i386
BOCHS=bochs
CC=gcc

.PHONY: clean bochs-run


obj/%.o: boot/%.S
	@if [ ! -d obj ]; then mkdir -p obj; fi
	$(CC) -m32 -c -Iboot/ $< -o obj/$*.o
	$(OBJCOPY) -j .text -O binary obj/$*.o

# bootsect.o: boot/bootsect.S
# 	$(CC) -m32 -c boot/bootsect.S -o obj/bootsect.o
# 	$(OBJCOPY) -j .text -O binary obj/bootsect.o
# 
# loader.o: boot/loader.S
# 	$(CC) -m32 -c boot/loader.S -o obj/loader.o
# 	$(OBJCOPY) -j .text -O binary obj/loader.o

kernel.img: obj/bootsect.o obj/loader.o obj/init.bin
	bximage -hd=60M -mode=create -q kernel.img 
	dd if=obj/bootsect.o of=kernel.img bs=512 count=1 conv=notrunc
	dd if=obj/loader.o of=kernel.img bs=512 count=20 conv=notrunc seek=2
	dd if=obj/init.bin of=kernel.img bs=512 count=100 conv=notrunc seek=9

obj/init.bin: kern/init/init.c
	gcc -m32 $< -c -o obj/init.o
	ld -m elf_i386 obj/init.o -T lds -e main -o obj/init.bin -Ttext 0xc0001500

run: kernel.img
	$(QEMU) -boot c -hda kernel.img

clean: 
	-@rm -f -r obj bochs.out kernel.img


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
