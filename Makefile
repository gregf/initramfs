all: mount clean my_initramfs.cpio.gz copy umount

mount:
	sudo mount /boot || exit 1
umount:
	sudo umount /boot
copy:
	cp my_initramfs.cpio.gz /boot || exit 1

my_initramfs.cpio.gz: config.txt init
	/usr/src/linux/usr/gen_init_cpio ./config.txt \
		|gzip -c >my_initramfs.cpio.gz || exit 1
clean:
	rm -f /boot/old_initramfs.cpio.gz
	mv /boot/my_initramfs.cpio.gz /boot/old_initramfs.cpio.gz
	rm -f my_initramfs.cpio.gz
