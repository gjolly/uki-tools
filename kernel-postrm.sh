#!/bin/sh -e

version="$1"

command -v efibootmgr >/dev/null 2>&1 || exit 0

# passing the kernel version is required
if [ -z "${version}" ]; then
  echo >&2 "W: unified-kernel-image: ${DPKG_MAINTSCRIPT_PACKAGE:-kernel package} did not pass a version number"
  exit 2
fi

uki_path="/boot/efi/EFI/ubuntu/kernel-$version.efi"
if [ -e "$uki_path" ]; then
  rm -f "$uki_path"
fi

boot_num=$(efibootmgr | grep "$version" | sed 's#^Boot\([0-9A-F]\+\)\*.*$#\1#g')
if [ -n "$boot_num" ]; then
  efibootmgr -b "$boot_num" -B
fi
