FROM alpine:3.8
RUN apk add --no-cache gcc=6.4.0-r9 make=4.2.1-r2 qemu-system-i386=2.12.0-r3 qemu-ui-curses=2.12.0-r3  && \
    rm -rf /var/cache/apk/*
