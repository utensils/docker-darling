#!/usr/bin/env bash
# Copy in osxcross macports
cp -rv /Volumes/SystemRoot/osxcross/target/macports/pkgs/opt/local/lib /usr/local/lib
cp -rv /Volumes/SystemRoot/osxcross/target/macports/pkgs/opt/local/libexec /usr/local/libexec
mkdir -p /Users/darling/Library/Application Support
