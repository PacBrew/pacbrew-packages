[![pacbrew.sh](https://github.com/PacBrew/pacbrew-packages/actions/workflows/pacbrew.yml/badge.svg)](https://github.com/PacBrew/pacbrew-packages/actions/workflows/pacbrew.yml)

PacBrew is a pacman based package manager for building and/or managing toolchains and libraries to ease homebrew developement. PacBrew is highly inspired by [devkitPro](https://github.com/devkitPro/pacman-packages) pacman.

#### Install pacman package manager
<details>
  <summary>ubuntu 24.04</summary>
  
  ```
  sudo apt install pacman-package-manager makepkg libarchive-tools build-essential autoconf libtool cmake git curl
  ```
</details>
<details>
  <summary>ubuntu 22.04 (manually install 24.04 debs)</summary>
  
  ```
  sudo apt -y install libarchive-tools build-essential autoconf libtool cmake git curl
  wget http://launchpadlibrarian.net/635298936/libalpm13_13.0.2-3_amd64.deb
  wget http://launchpadlibrarian.net/635298938/pacman-package-manager_6.0.2-3_amd64.deb
  wget http://launchpadlibrarian.net/635298937/makepkg_6.0.2-3_amd64.deb
  sudo dpkg -i libalpm13_13.0.2-3_amd64.deb pacman-package-manager_6.0.2-3_amd64.deb makepkg_6.0.2-3_amd64.deb
  sudo apt -y -f install
  ```
</details>

#### Configure pacman package manager
  - edit pacman configuration
  ```
  sudo nano /etc/pacman.conf
  ```
  - add pacbrew repository
  ```
  [pacbrew]
  SigLevel = Optional TrustAll
  Server = http://pacbrew.mydedibox.fr/packages/
  ```
 - update pacman databases:
  ```
  sudo pacman -Sy
  ```

#### Install ps4 openorbis toolchain and portlibs
  ```
  sudo pacman -S ps4-openorbis ps4-openorbis-portlibs
  ```
  - have a look at [PacBrew openorbis sample](https://github.com/PacBrew/ps4-openorbis-sample)

#### Install dreamcast (KallistiOS) toolchain and portlibs (wip):
  ```
  sudo pacman -S dc-toolchain dc-portlibs
  ```
