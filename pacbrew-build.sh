#!/bin/bash

set -e

b() {
	pushd $1
	rm -rf pkg src *.pkg.tar.gz
	pacbrew-makepkg -C -f
	sudo pacbrew-pacman --noconfirm -U *.pkg.tar.gz
	popd
}

. pacbrew-packages.sh
