#!/bin/bash

set -e

PACBREW_PACMAN_URL="https://github.com/PacBrew/pacbrew-pacman/releases/download/pacbrew-release-1.0/pacbrew-pacman-1.0.deb"
COL_GREEN='\033[0;32m'
COL_NONE='\033[0m'

function check_pacman {
  if ! command -v pacbrew-pacman &> /dev/null
  then
    echo -e "${COL_GREEN}check_pacman:${COL_NONE} pacbrew-pacman not found, installing..."
    wget $PACBREW_PACMAN_URL &> /dev/null
    sudo dpkg -i pacbrew-pacman-1.0.deb &> /dev/null
    rm -f pacbrew-pacman-1.0.deb &> /dev/null
  fi
  echo -e "${COL_GREEN}check_pacman:${COL_NONE} synching repositories..."
  sudo pacbrew-pacman -Sy &> /dev/null
  echo -e "${COL_GREEN}check_pacman:${COL_NONE} ok"
}

function install_local_package {
  sudo pacbrew-pacman --noconfirm -U $1 &> /dev/null || exit 1
}

function install_remote_package {
  sudo pacbrew-pacman --noconfirm --needed -S $1 &> /dev/null || exit 1
}

function build_package {
  # build package
  pushd "$1" &> /dev/null || exit 1
  rm -rf *.pkg.tar.xz &> /dev/null || exit 1
  pacbrew-makepkg -C -f || exit 1
  popd &> /dev/null || exit 1
}

function build_packages {

  remote_packages=`pacbrew-pacman -Sl`

  # parse args
  while test $# -gt 0
  do
    case "$1" in
      -f) echo -e "${COL_GREEN}build_packages${COL_NONE}: force rebuild all packages"
          PACBREW_BUILD_ALL=true
        ;;
      -u) echo -e "${COL_GREEN}build_packages${COL_NONE}: upload packages to pacbrew repo with specified user"
          PACBREW_UPLOAD=true
          shift && PACBREW_SSH_USER="$1"
        ;;
    esac
    shift
  done

  # download repo files from server, if needed
  if [ $PACBREW_UPLOAD ]; then
    echo -e "${COL_GREEN}build_packages:${COL_NONE} downloading pacbrew repo..."
    rm -rf pacbrew-repo && mkdir -p pacbrew-repo
    scp $PACBREW_SSH_USER@mydedibox.fr:/var/www/pacbrew/packages/pacbrew.* pacbrew-repo || exit 1
  fi

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
    if [ $PACBREW_BUILD_ALL ] || [ "$local_pkgverrel" != "$remote_pkgverrel" ]; then
      echo -e "${COL_GREEN}build_packages:${COL_NONE} new package: ${COL_GREEN}$local_pkgname${COL_NONE} ($remote_pkgverrel => $local_pkgverrel)"
      echo -e "${COL_GREEN}build_packages:${COL_NONE} building ${COL_GREEN}$local_pkgname${COL_NONE} ($local_pkgverrel)"
      build_package "$line"
      # install built package
      echo -e "${COL_GREEN}build_packages:${COL_NONE} installing ${COL_GREEN}$line/$local_pkgname-$local_pkgverrel.pkg.tar.xz${COL_NONE}"
      install_local_package $line/*.pkg.tar.xz
      if [ $PACBREW_UPLOAD ]; then
        echo -e "${COL_GREEN}build_packages:${COL_NONE} uploading ${COL_GREEN}$local_pkgname${COL_NONE} to pacbrew repo"
        scp $line/*.pkg.tar.xz $PACBREW_SSH_USER@mydedibox.fr:/var/www/pacbrew/packages/ || exit 1
        pacbrew-repo-add pacbrew-repo/pacbrew.db.tar.gz $line/*.pkg.tar.xz || exit 1
      fi
    else
      # always install deps for later packges build
      echo -e "${COL_GREEN}build_packages: $local_pkgname${COL_NONE} found in database, installing..."
      install_remote_package "$local_pkgname"
    fi

  done < pacbrew-packages.cfg

  # upload updated repo files and cleanup
  if [ $PACBREW_UPLOAD ]; then
    echo -e "${COL_GREEN}build_packages:${COL_NONE} updating pacbrew repo with new packages..."
    scp pacbrew-repo/* $PACBREW_SSH_USER@mydedibox.fr:/var/www/pacbrew/packages/ || exit 1
    rm -rf pacbrew-repo
  fi

  echo -e "${COL_GREEN}build_packages:${COL_NONE} all done !"
}

check_pacman
build_packages "$@"

