#!/bin/sh

# setuid root on darling binary
sudo chmod 4755 /usr/local/bin/darling

# Setup kernel module paths
sudo mkdir -p /lib/modules/"$(uname -r)"
sudo ln -s /usr/src/linux-headers-"$(uname -r)" /lib/modules/"$(uname -r)"/build

# Build kernel module
cd /usr/local/src/darling/build || exit 1
sudo make lkm -j"$(nproc)"
sudo make lkm_install
sudo xz -d /lib/modules/"$(uname -r)"/extra/darling-mach.ko.xz

# Try to unload any existing darling modules
sudo rmmod darling-mach.ko

# Load new module
sudo insmod /lib/modules/"$(uname -r)"/extra/darling-mach.ko

# Work around existing overlayfs
sudo mount -t tmpfs tmpfs /home/darling

# Setup darling env
darling shell < /usr/local/bin/darling-setup.sh

if [ $# -eq 0 ]; then
	echo "No command was given to run, exiting."
	exit 1
else
	# Ensure we don't get left in wrong directory after module build
	cd /home/darling || exit 1
	exec "$@"
fi
