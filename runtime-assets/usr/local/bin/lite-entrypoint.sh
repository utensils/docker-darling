#!/usr/bin/env bash
# Load the kernel module if needed
echo "Attempting to load darling-mach"
sudo modprobe darling-mach
# Prepare for OverlayFS
echo "Preparing OverlayFS"
sudo mount -t tmpfs tmpfs /home/darling
echo "Executing $@"
exec sudo "$@"
