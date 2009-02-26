#!/bin/bash
# Copyright 2007-2008 Mike Kelly <pioto@pioto.org>
# Released under the terms of the GNU General Public License v2
#
# Based upon a script from: http://www.disciplina.net/howto/initscript
#
# Modified by Greg Fitzgerald <netzdamon@gmail.com>

# Perty colors
einfo() { echo -ne " \033[32;01m*\033[0m ${@}\n"; }
ewarn() { echo -ne " \033[33;01m*\033[0m ${@}\n"; }
eerror() { echo -ne " \033[31;01m*\033[0m ${@}\n"; }

# If the drive and or key is not found ask the user to specify a alternative
# location to try.
askfor_key() {
    while [ 1 ]
    do
        ewarn "Could not find your key, please tell us where it is."
        echo "Input Drive: (/dev/sda2)"
        read loc
        echo "Key File: (/secret/keys/mykey.gpg)"
        read key
        umount -f ${key_location} 
        mount -o ro ${loc} ${key_location} || askfor_key
        if [ -z "${loc}" ] || [ -z "${key}" ]
        then
            ewarn "You have to enter something dumbass!"
        elif [ -b "${loc}" ] && [ -e "${key_location}/${key}" ]
        then
            einfo "found device! Trying again..."
            /sbin/cryptsetup --key-file ${key_location}/${key} luksOpen /dev/sdb1 sdb1_storage || askfor_key
            return
        else
            ewarn "device or key not found :("
        fi
    done
}

# Watch /dev for our specified drive to appear. If this times out we will go to
# askfor_key
waitfor_drives() {
    for device in $@; do
        ewarn "Waiting for device ${device}..." 
        slumber=${TIMEOUT}
        while [ ${slumber} -gt 0 -a ! -b "${device}" ]; do 
                /bin/sleep 0.1 
                slumber=$(( ${slumber} - 1 )) 
        done 
        einfo "Found ${device}!" 
    done
}

decrypt_drives() {
    if [ -z ${DRIVES} ]; then
        eerror "No Drives to decrypt!"
        return
    fi
    for dk in ${DRIVES[@]}
    do
        drive=`echo -n $dk | cut -d: -f1`
        key=`echo -n $dk | cut -d: -f2`
        cname=`echo -n $drive | cut -d"/" -f3`
        
        einfo "Decrypting ${drive}..."

        if ! $(/sbin/cryptsetup isLuks ${drive}); then 
            eerror "${drive} is not encrypted dipshit!"
        else 
            if [ "${key}" == "false" ]; then
                /sbin/cryptsetup luksOpen ${drive} sda2_crypt || askfor_key
            else
                /sbin/cryptsetup --key-file ${key_location}/${key} luksOpen ${drive} ${cname}_crypt || askfor_key
            fi
        fi
    done
}

undo_vars() {
    unset key_location
    unset key
    unset DRIVES
    unset loc
    unset device
    unset drive
    unset cname
    unset dk
    unset slumber
}

# vim: set ft=sh tw=78:
