#!/bin/sh -e

version="$1"

command -v generate-uki >/dev/null 2>&1 || exit 0
command -v efibootmgr >/dev/null 2>&1 || exit 0

# passing the kernel version is required
if [ -z "${version}" ]; then
  echo >&2 "W: unified-kernel-image: ${DPKG_MAINTSCRIPT_PACKAGE:-kernel package} did not pass a version number"
  exit 2
fi

uki_path="/boot/efi/EFI/ubuntu/kernel-$version.efi"
if [ ! -e "$uki_path" ]; then
  generate-uki \
    --secureboot /etc/sbkeys \
    --kernel /boot/vmlinuz-$version \
    --initrd /boot/initrd.img-$version \
    --output "$uki_path"
fi

# the partition here should not be hardcoded
boot_num=$(efibootmgr | grep "$version" | sed 's#^Boot\([0-9]\+\)\*.*$#\1#g')

if [ -z "$boot_num" ]; then
  efibootmgr --create \
    --disk /dev/nvme0n1 --part 1 \
    --label "Ubuntu $version" \
    --loader '\EFI\ubuntu\shimx64.efi' \
    -u "\\EFI\\ubuntu\\kernel-$version.efi"
fi
