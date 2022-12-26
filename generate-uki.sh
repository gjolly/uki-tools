#!/bin/bash -eu

# Set default variables

OUTPUT_PATH="unified-kernel-image.efi"
EFI_STUB="/usr/lib/systemd/boot/efi/linuxx64.efi.stub"
KERNEL_PATH="/boot/vmlinuz"
INITRD_PATH="/boot/initrd.img"
SB_PATH="./keys"
SHOW_HELP=NO

# functions

function verify-pre-requisites {
  if [ ! -f "$EFI_STUB" ]; then
    echo "Cannot find systemd EFI stub" >&2
    echo "If you are on Ubuntu, verify that systemd-boot-efi is installed" >&2
    exit 255
  fi
}

function print-usage {
  cat << EOF >&2
Build a Unified Kernel Image and sign it
  --kernel <path>       vmlinuz path
                        Value: $KERNEL_PATH
  --initrd <path>       initrd path
                        Value: $INITRD_PATH
  --efi-stub <path>     Path to the kernel efi stub
                        Value: $EFI_STUB
  --output <path>       UKI output path
                        Value: $OUTPUT_PATH
  --secureboot <path>   Path to secureboot folder. The folder should contain sb.crt and sb.key
                        Value: $SB_PATH
  --verbose             Set -x, usefull for debugging
  --help                Print this help
EOF
}

# parse params

while [[ $# -gt 0 ]]
do
  case $1 in
    --kernel|-k)
      KERNEL_PATH=$2
      shift
      ;;
    --initrd|-i)
      INITRD_PATH=$2
      shift
      ;;
    --efi-stub|-e)
      EFI_STUB=$2
      shift
      ;;
    --output|-o)
      OUTPUT_PATH=$2
      shift
      ;;
    --secureboot|-s)
      SB_PATH=$2
      shift
      ;;
    --verbose|-v)
      set -x
      ;;
    --help|-h)
      SHOW_HELP=YES
      ;;
    *)
      echo "error: unknown option '$1'" >&2
      exit 255
      ;;
  esac
  shift
done

if [ "$SHOW_HELP" = "YES" ]
then
    print-usage
    exit 255
fi

verify-pre-requisites

KERNEL_CMDLINE=/tmp/cmdline.txt
SPLASH_IMG=/tmp/splash.bmp

cat /proc/cmdline | cut -f '2-' -d' ' > "$KERNEL_CMDLINE"
cp /sys/firmware/acpi/bgrt/image "$SPLASH_IMG"

OS_RELEASE="/usr/lib/os-release"
VMLINUZ="$(realpath $KERNEL_PATH)"
INITRD="$(realpath $INITRD_PATH)"

# compute sections offsets

osrel_offs=$(objdump -h "$EFI_STUB" | awk 'NF==7 {size=strtonum("0x"$3); offset=strtonum("0x"$4)} END {print size + offset}')
cmdline_offs=$((osrel_offs + $(stat -Lc%s "$OS_RELEASE")))
splash_offs=$((cmdline_offs + $(stat -Lc%s "$KERNEL_CMDLINE")))
linux_offs=$((splash_offs + $(stat -Lc%s "$SPLASH_IMG")))
initrd_offs=$((linux_offs + $(stat -Lc%s "$VMLINUZ")))

# build the UKI

UNSIGNE_UKI="/tmp/unified-kernel-image.efi"
objcopy \
   --add-section .osrel="$OS_RELEASE" --change-section-vma .osrel="$(printf 0x%x $osrel_offs)" \
   --add-section .cmdline=$KERNEL_CMDLINE --change-section-vma .cmdline="$(printf 0x%x $cmdline_offs)" \
   --add-section .splash=$SPLASH_IMG --change-section-vma .splash="$(printf 0x%x $splash_offs)" \
   --add-section .linux="$VMLINUZ" --change-section-vma .linux="$(printf 0x%x $linux_offs)" \
   --add-section .initrd="$INITRD" --change-section-vma .initrd="$(printf 0x%x $initrd_offs)" \
   "$EFI_STUB" \
   "$UNSIGNE_UKI"

# Sign the image if a key is found

if [ -e "$SB_PATH/sb.key" ]; then
  sbsign --cert "$SB_PATH/sb.crt" --key "$SB_PATH/sb.key" --output "$OUTPUT_PATH" "$UNSIGNE_UKI"
  rm "$UNSIGNE_UKI"
else
  mv "$UNSIGNE_UKI" "$OUTPUT_PATH"
fi
