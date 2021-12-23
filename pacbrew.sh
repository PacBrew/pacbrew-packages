#!/bin/bash

set -e

PACBREW_PACMAN_URL="https://github.com/PacBrew/pacbrew-pacman/releases/download/pacbrew-release-1.0/pacbrew-pacman-1.0.deb"

function check_pacman {
  echo "check_pacman..."
  if ! command -v pacbrew-pacman &> /dev/null
  then
    echo "check_pacman: pacbrew-pacman not found, installing..."
    wget $PACBREW_PACMAN_URL &> /dev/null
    sudo dpkg -i pacbrew-pacman-1.0.deb &> /dev/null
    rm -f pacbrew-pacman-1.0.deb &> /dev/null
  fi
  echo "check_pacman: synching repositories..."
  sudo pacbrew-pacman -Sy &> /dev/null
  echo "check_pacman: ok"
}

function install_remote_package {
  echo "install_remote_package: $1"
  sudo pacbrew-pacman --noconfirm --needed -S $1 &> /dev/null
}

function build_package {
  echo "build_package: building "$1""
  # build package
  pushd "$1" &> /dev/null
  rm -rf *.pkg.tar.xz &> /dev/null
  pacbrew-makepkg -C -f
  popd &> /dev/null
}

function check_new {

  echo "check_new..."

  argv1=$1
  remote_packages=`pacbrew-pacman -Sl`

  while read line; do
    # skip empty lines and comments
    if [ -z "$line" ] || [[ $line == \#* ]] ; then
      continue
    fi

    # get local package name and version
    local_pkgname=`cat $line/PKGBUILD | grep pkgname= | sed 's/pkgname=//g'`
    local_pkgver=`cat $line/PKGBUILD | grep pkgver= | sed 's/pkgver=//g'`
    local_pkgrel=`cat $line/PKGBUILD | grep pkgrel= | sed 's/pkgrel=//g'`
    local_pkgdeps=`cat $line/PKGBUILD | grep depends= | sed -n "s/^.*'\(.*\)'.*$/\1/ p" | tr '\n' ' ' | awk '{$1=$1};1'`
    local_pkgverrel="$local_pkgver-$local_pkgrel"
    
    # get remote package name and version
    remote_pkgname=`echo "$remote_packages" | grep -w $local_pkgname | awk '{print $2}'`
    remote_pkgverrel=`echo "$remote_packages" | grep -w $local_pkgname | awk '{print $3}'`
    if [ -z "$remote_pkgverrel" ]; then
      remote_pkgverrel="n/a"
    fi

    # only build packages that are not available (version differ)
    if [ "$argv1" ==  "-f" ] || [ "$local_pkgverrel" != "$remote_pkgverrel" ]; then
      echo "check_new: new package detected: $local_pkgname ($remote_pkgverrel => $local_pkgverrel)"
      build_package "$line"
    else
      # always install deps for later packges build
      install_remote_package "$local_pkgname"
    fi

  done < pacbrew-packages.cfg
}

check_pacman
check_new $1

