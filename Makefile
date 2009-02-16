initramfs=initramfs.igz

all: mount clean ramdisk copy umount

mount:
	sudo mount /boot || exit 1
umount:
	sudo umount /boot
copy:
	cp ${initramfs} /boot || exit 1

ramdisk: config.txt init
	/usr/src/linux/usr/gen_init_cpio ./config.txt \
		|gzip -c >${initramfs} || exit 1
clean:
	rm -f /boot/old_${initramfs}
	mv /boot/${initramfs} /boot/old_${initramfs} || exit 0
	rm -f ${initramfs}

extract: ramdisk
	rm -rf init_fs
	mkdir -p init_fs
	cd init_fs && zcat ../my_initramfs.cpio.gz | (while true; do cpio -i -d -H newc --no-absolute-filenames >/dev/null 2>&1 || exit 0; done)

compress:
	cd init_fs && find . | cpio -H newc -o > ../initramfs.cpio
	cat initramfs.cpio | gzip > ${initramfs} 
