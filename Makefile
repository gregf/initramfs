all: mount my_initramfs.cpio.gz copy umount clean

mount:
	sudo mount /boot
umount:
	sudo umount /boot
copy:
	cp my_initramfs.cpio.gz /boot
my_initramfs.cpio.gz: config.txt init
	/usr/src/linux/usr/gen_init_cpio ./config.txt \
		|gzip -c >my_initramfs.cpio.gz
clean:
	rm -f my_initramfs.cpio.gz
