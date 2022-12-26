#!/bin/bash -eu

kernel_efi=$1

if [ ! -e efi.disk ]; then
  qemu-img create efi.disk 1G
  sgdisk --zap-all efi.disk
  sgdisk efi.disk \
    --new=1:0: \
    --typecode=1:ef00

  modprobe nbd
  qemu-nbd --connect=/dev/nbd0 -f raw ./efi.disk

  sleep 5
  mkfs.vfat -F 32 -n UEFI /dev/nbd0p1

  mkdir -p /tmp/uefi
  mount /dev/nbd0p1 /tmp/uefi

  mkdir -p /tmp/uefi/EFI/BOOT
  cp "$kernel_efi" /tmp/uefi/EFI/BOOT/BOOTX64.EFI

  umount /tmp/uefi
  rm -r /tmp/uefi

  qemu-nbd --disconnect /dev/nbd0
fi

qemu-system-x86_64 -m 4G \
  -nographic -snapshot \
  -drive if=pflash,format=raw,unit=0,file=/usr/share/OVMF/OVMF_CODE.fd,readonly=on \
  -drive if=pflash,format=raw,unit=1,file=/usr/share/OVMF/OVMF_VARS.fd \
  -drive if=virtio,format=raw,file=efi.disk
