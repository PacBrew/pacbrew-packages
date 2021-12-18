#!/bin/bash

set -e

function build {
  b() {
    pushd $1
    rm -rf *.pkg.tar.xz
    pacbrew-makepkg -C -f
    sudo pacbrew-pacman --noconfirm -U *.pkg.tar.xz
    popd
  }

  if [ -z "$1" ]; then
    # build all packages
    . pacbrew-packages.sh
  else
    # build specified package
    pushd $1
    rm -rf *.pkg.tar.xz
    pacbrew-makepkg -C -f
    sudo pacbrew-pacman --noconfirm -U *.pkg.tar.xz
    popd
  fi
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
  if [ -z "$1" ]; then
    # update and upload all packages
    . pacbrew-packages.sh
  else
    # update and upload specified package
    scp $1/*.pkg.tar.xz mydedibox.fr:/var/www/pacbrew/packages/
    pacbrew-repo-add pacbrew-repo/pacbrew.db.tar.gz $1/*.pkg.tar.xz
  fi
  # upload updated repo files
  scp pacbrew-repo/* mydedibox.fr:/var/www/pacbrew/packages/
  # cleanup
  rm -rf pacbrew-repo
}

if [ "$1" == "upload" ]; then
  build "$2"
  upload "$2"
else
  build "$1"
fi

