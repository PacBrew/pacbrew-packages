#!/bin/bash

set -e

PACBREW_PACMAN_URL="https://github.com/PacBrew/pacbrew-pacman/releases/download/v1.1/pacbrew-pacman-1.1.deb"
COL_GREEN='\033[0;32m'
COL_NONE='\033[0m'

function check_pacman {
  if ! command -v pacbrew-pacman &> /dev/null
  then
    echo -e "${COL_GREEN}check_pacman:${COL_NONE} pacbrew-pacman not found, installing..."
    wget $PACBREW_PACMAN_URL &> /dev/null
    sudo dpkg -i pacbrew-pacman-1.1.deb &> /dev/null
    rm -f pacbrew-pacman-1.1.deb &> /dev/null
  fi
  echo -e "${COL_GREEN}check_pacman:${COL_NONE} synching repositories..."
  sudo -E pacbrew-pacman -Syy &> /dev/null
  echo -e "${COL_GREEN}check_pacman:${COL_NONE} ok"
}

# get_pkg_info PKGBUILD ARCH
function get_pkg_info() {
  pushd $(dirname "$1") &> /dev/null || exit 1
  local pkginfo=`CARCH=$2 pacbrew-makepkg --printsrcinfo` &> /dev/null || exit 1
  popd &> /dev/null || exit 1
  echo "$pkginfo"
}

# get_pkg_var PKGINFO VAR
function get_pkg_var() {
  echo `echo "$1" | grep "$2 =" | cut -d= -f2 | xargs`
}

# get_pkg_name PKGINFO
function get_pkg_name() {
  echo `get_pkg_var "$1" "pkgname"`
}

# get_pkg_ver PKGINFO
function get_pkg_ver() {
  echo `get_pkg_var "$1" "pkgver"`
}

# get_pkg_rel PKGINFO
function get_pkg_rel() {
  echo `get_pkg_var "$1" "pkgrel"`
}

# get_pkg_arch PKGINFO
function get_pkg_arch() {
  echo `get_pkg_var "$1" "arch"`
}

# get_pkg_deps PKGINFO
function get_pkg_deps() {
  echo `get_pkg_var "$1" "depends"`
}

# get_pkg_groups PKGINFO
function get_pkg_groups() {
  echo `get_pkg_var "$1" "groups"`
}

# is_android_portlibs_pkg LINE
function is_android_portlibs_pkg() {
  if [[ "$1" == *"android-portlibs"* ]]; then
    # 0 = true
    return 0
  else
    # 1 = false
    return 1
  fi
}

function install_local_package {
  sudo pacbrew-pacman --noconfirm -U $1 &> /dev/null || exit 1
}

function install_remote_package {
  sudo pacbrew-pacman --noconfirm --needed -S $1 &> /dev/null || exit 1
}

# build_package PKGPATH ARCH
function build_package {
  # build package
  pushd "$1" &> /dev/null || exit 1
  rm -rf *.pkg.tar.xz &> /dev/null || exit 1
  CARCH=$2 pacbrew-makepkg -C -f || exit 1
  popd &> /dev/null || exit 1
}

function build_packages {
  PACBREW_SSH_HOST="mydedibox.fr"
  remote_packages=`pacbrew-pacman -Sl`

  # parse args
  while test $# -gt 0
  do
    case "$1" in
      -f) echo -e "${COL_GREEN}build_packages${COL_NONE}: force rebuild all packages"
          PACBREW_BUILD_ALL=true
        ;;
      -u) echo -e "${COL_GREEN}build_packages${COL_NONE}: uploading packages to pacbrew repo with specified user"
          PACBREW_UPLOAD=true
          shift && PACBREW_SSH_USER="$1"
        ;;
      -h) echo -e "${COL_GREEN}build_packages${COL_NONE}: uploading packages to pacbrew repo with specified host"
          PACBREW_UPLOAD=true
          shift && PACBREW_SSH_HOST="$1"
        ;;
    esac
    shift
  done

  # download repo files from server, if needed
  if [ $PACBREW_UPLOAD ]; then
    echo -e "${COL_GREEN}build_packages:${COL_NONE} downloading pacbrew repo..."
    rm -rf pacbrew-repo && mkdir -p pacbrew-repo
    scp $PACBREW_SSH_USER@$PACBREW_SSH_HOST:/var/www/pacbrew/packages/pacbrew.* pacbrew-repo || exit 1
  fi

  while read line; do
    # skip empty lines and comments
    if [ -z "$line" ] || [[ $line == \#* ]] ; then
      continue
    fi

    # set target arch
    ARCHS="any"

    # android portlibs can be aarch64 or armv7a
    if is_android_portlibs_pkg $line; then
      ARCHS="aarch64 armv7a x86_64"
    fi

    for ARCH in $ARCHS; do
      # get local package info string
      PKGINFO=$(get_pkg_info "$line/PKGBUILD" $ARCH)

      # get local package name and version from info string
      local_pkgname=$(get_pkg_name "$PKGINFO")
      local_pkgver=$(get_pkg_ver "$PKGINFO")
      local_pkgrel=$(get_pkg_rel "$PKGINFO")
      local_pkgdeps=$(get_pkg_deps "$PKGINFO")
      local_pkggrps=$(get_pkg_groups "$PKGINFO")
      local_pkgverrel="$local_pkgver-$local_pkgrel"
      #echo "name: $local_pkgname, version: $local_pkgverrel, groups: $local_pkggrps, depends: $local_pkgdeps"
      #continue

      # get remote package name and version
      remote_pkgname=`echo "$remote_packages" | grep "$local_pkgname " | awk '{print $2}'`
      remote_pkgverrel=`echo "$remote_packages" | grep "$local_pkgname " | awk '{print $3}'`
      if [ -z "$remote_pkgverrel" ]; then
        remote_pkgverrel="n/a"
      fi

      # only build packages that are not available (version differ)
      if [ $PACBREW_BUILD_ALL ] || [ "$local_pkgverrel" != "$remote_pkgverrel" ]; then
        echo -e "${COL_GREEN}build_packages:${COL_NONE} new package: ${COL_GREEN}$local_pkgname${COL_NONE} ($remote_pkgverrel => $local_pkgverrel)"
        echo -e "${COL_GREEN}build_packages:${COL_NONE} building ${COL_GREEN}$local_pkgname${COL_NONE} ($local_pkgverrel)"
        build_package "$line" $ARCH
        # install built package
        echo -e "${COL_GREEN}build_packages:${COL_NONE} installing ${COL_GREEN}$line/$local_pkgname-$local_pkgverrel.pkg.tar.xz${COL_NONE}"
        install_local_package $line/*.pkg.tar.xz
        if [ $PACBREW_UPLOAD ]; then
          echo -e "${COL_GREEN}build_packages:${COL_NONE} uploading ${COL_GREEN}$local_pkgname${COL_NONE} to pacbrew repo"
          scp $line/*.pkg.tar.xz $PACBREW_SSH_USER@$PACBREW_SSH_HOST:/var/www/pacbrew/packages/ || exit 1
          pacbrew-repo-add pacbrew-repo/pacbrew.db.tar.gz $line/*.pkg.tar.xz || exit 1
        fi
      else
        # always install deps for later packges build
        echo -e "${COL_GREEN}build_packages: $local_pkgname${COL_NONE} is up to date, installing if needed..."
        install_remote_package "$local_pkgname"
      fi
    done
  done < pacbrew-packages.cfg

  # upload updated repo files and cleanup
  if [ $PACBREW_UPLOAD ]; then
    echo -e "${COL_GREEN}build_packages:${COL_NONE} updating pacbrew repo with new packages..."
    scp pacbrew-repo/* $PACBREW_SSH_USER@$PACBREW_SSH_HOST:/var/www/pacbrew/packages/ || exit 1
    rm -rf pacbrew-repo
  fi

  echo -e "${COL_GREEN}build_packages:${COL_NONE} all done !"
}

check_pacman
build_packages "$@"

