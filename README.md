![pacbrew.sh](https://github.com/PacBrew/pacbrew-packages/actions/workflows/pacbrew.yml/badge.svg)

#### Install ps4 openorbis toolchain and portlibs (ubuntu):

  - download pacbrew-pacman: `wget https://github.com/PacBrew/pacbrew-pacman/releases/download/pacbrew-release-1.0/pacbrew-pacman-1.0.deb`
  - install pacbrew-pacman: `sudo dpkg -i pacbrew-pacman-1.0.deb`
  - update pacbrew online database: `sudo pacbrew-pacman -Sy`
  - install ps4 openorbis toolchain (clang, musl, tools, ...): `sudo pacbrew-pacman -S ps4-openorbis`
  - install ps4 openorbis portlibs (zlib, sdl2, ...): `sudo pacbrew-pacman -S ps4-openorbis-portlibs`
  - set OO_PS4_TOOLCHAIN to `/opt/pacbrew/ps4/openorbis`
