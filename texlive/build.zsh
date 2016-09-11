#!/bin/zsh

set -e

cd /root/
wget http://mirror.rit.edu/CTAN/systems/texlive/Images/texlive2016.iso
sha256sum --check texlive2016.iso.sha256

mkdir tl
mount -o loop texlive2016.iso tl
tl/install-tl
umount tl
rm texlive2016.iso
