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

gen-docker: Dockerfile
	docker build -t osdocker .

docker-make: 
	docker run \
		--rm \
		--volume $(PWD):/home/ \
		osdocker \
		make bootsect.o -C /home/

docker-run:
	docker run \
		--rm \
		-it \
		--volume $(PWD):/home/ \
		osdocker \
		$(QEMU) -boot a -fda /home/bootsect.o -display curses 
