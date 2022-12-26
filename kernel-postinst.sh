#!/bin/sh -e

version="$1"

command -v generate-uki >/dev/null 2>&1 || exit 0
command -v efibootmgr >/dev/null 2>&1 || exit 0

# passing the kernel version is required
if [ -z "${version}" ]; then
        echo >&2 "W: unified-kernel-image: ${DPKG_MAINTSCRIPT_PACKAGE:-kernel package} did not pass a version number"
        exit 2
fi

generate-uki --kernel /boot/vmlinuz-$version --kernel /boot/initrd.img-$version --output "/boot/efi/EFI/ubuntu/kernel-$version.efi"

# the partition here should not be hardcoded
efibootmgr --create --disk /dev/nvme0n1 --part 1 --label "Ubuntu $version UKI" --loader '\EFI\ubuntu\shimx64.efi' -u "\\EFI\\ubuntu\\kernel-$version.efi"
