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

extract: my_initramfs.cpio.gz
	rm -rf init_fs
	mkdir -p init_fs
	cd init_fs && zcat ../my_initramfs.cpio.gz | (while true; do cpio -i -d -H newc --no-absolute-filenames >/dev/null 2>&1 || exit 0; done)
compress:
	#compress contents for tmpdir
