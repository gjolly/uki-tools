#!/bin/bash -eu

MODE="${1:-install}"

if [ $MODE == "uninstall" ]; then
  rm /etc/kernel/postinst.d/zz-unified-kernel-image
  rm /etc/kernel/postrm.d/zz-unified-kernel-image
  rm /usr/bin/generate-uki
else
  cp ./generate-uki.sh /usr/bin/generate-uki
  cp ./kernel-postinst.sh /etc/kernel/postinst.d/zz-unified-kernel-image
  cp ./kernel-postrm.sh /etc/kernel/postrm.d/zz-unified-kernel-image
fi
