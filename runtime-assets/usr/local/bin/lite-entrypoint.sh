#!/usr/bin/env bash
# Prepare for OverlayFS
echo "Preparing OverlayFS"
sudo mount -t tmpfs tmpfs /home/darling
echo "Executing $@"
exec sudo "$@"
