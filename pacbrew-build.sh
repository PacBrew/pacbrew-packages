#!/bin/bash

set -e

b() {
	pushd $1
	rm -rf pkg src *.pkg.tar.xz
	pacbrew-makepkg -C -f
	sudo pacbrew-pacman --noconfirm -U *.pkg.tar.xz
	popd
}

. pacbrew-packages.sh
