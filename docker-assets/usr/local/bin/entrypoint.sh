#!/bin/sh

#ln -s /lib/modules/4.15.0-22-generic /lib/modules/"$(uname -r)"

cd /home/darling/build
sudo make lkm -j"$(nproc)"
sudo make lkm_install
sudo xz -d /lib/modules/4.16.13-2-ARCH/extra/darling-mach.ko.xz
sudo insmod /lib/modules/4.16.13-2-ARCH/extra/darling-mach.ko

sudo mount -t tmpfs tmpfs /home/darling

# Setup darling env
darling shell < /usr/local/bin/darling-setup.sh

if [ $# -eq 0 ]; then
	echo "No command was given to run, exiting."
	exit 1
else
	exec "$@"
fi
