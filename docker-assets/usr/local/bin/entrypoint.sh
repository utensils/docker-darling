#!/bin/sh

# Build kernel module against arch linux kernel
# This will eventually be handled properly

sudo /usr/local/kernel-headers/arch_linux.sh

mkdir -p /home/darling/build
cd /home/darling/build
cmake ..
sudo make lkm -j"$(nproc)"
sudo make lkm_install
sudo xz -d /lib/modules/4.16.13-2-ARCH/extra/darling-mach.ko.xz
sudo insmod /lib/modules/4.16.13-2-ARCH/extra/darling-mach.ko

# Work around existing overlayfs
sudo mount -t tmpfs tmpfs /home/darling

# Setup darling env
sudo darling shell < /usr/local/bin/darling-setup.sh

if [ $# -eq 0 ]; then
	echo "No command was given to run, exiting."
	exit 1
else
	exec "$@"
fi
