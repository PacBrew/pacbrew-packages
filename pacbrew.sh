#!/bin/bash

set -e

function build {
	b() {
		pushd $1
		pacbrew-makepkg -C -f
		sudo pacbrew-pacman --noconfirm -U *.pkg.tar.xz
		popd
	}

	# build packages
	. pacbrew-packages.sh
}

function upload {
	b() {
		scp $1/*.pkg.tar.xz mydedibox.fr:/var/www/pacbrew/packages/
		pacbrew-repo-add pacbrew-repo/pacbrew.db.tar.gz $1/*.pkg.tar.xz
	}
	
	# cleanup repo directory
	rm -rf pacbrew-repo
	mkdir -p pacbrew-repo
	# get repo files from server
	scp mydedibox.fr:/var/www/pacbrew/packages/pacbrew.* pacbrew-repo
	# update and upload packages
	. pacbrew-packages.sh
	# upload updated repo files
	scp pacbrew-repo/* mydedibox.fr:/var/www/pacbrew/packages/
	# cleanup
	rm -rf pacbrew-repo
}

if [ "$1" == "upload" ]; then
	build
	upload
else
	build
fi

