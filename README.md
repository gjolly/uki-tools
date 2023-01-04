# Script to generate a Unified Kernel Unified

## secure boot pre-requisites

Follow this guide to generate and install your own secure boot keys: https://www.rodsbooks.com/efi-bootloaders/controlling-sb.html

A copy of `mkkeys.sh` is provided in this repository.

Make sure to add a copy of your own db (private key) and certificate under `/etc/sbkeys/sb.key` and `/etc/sbkeys/sb.crt`. The kernel install hooks provided in this repository will use this keys to sign the Unified Kernel Image.

## install/uninstall

To install:

```bash
sudo ./install
```

To uninstall:

```bash
sudo ./install uninstall
```
