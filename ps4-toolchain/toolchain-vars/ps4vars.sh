#!/usr/bin/env bash

export PACBREW=/opt/pacbrew
export ORBISDEV=${PACBREW}/ps4/toolchain
export PS4SDK=${PACBREW}/ps4/toolchain

export PATH=${ORBISDEV}/bin:$PATH
#export TOOL_PREFIX=orbis-
export CC=${ORBISDEV}/bin/clang
export CXX=${ORBISDEV}/bin/clang++
export AS=${ORBISDEV}/bin/orbis-as
export LD=${ORBISDEV}/bin/orbis-ld
export AR=${ORBISDEV}/bin/orbis-ar
export RANLIB=${ORBISDEV}/bin/orbis-ranlib
export NM=${ORBISDEV}/bin/orbis-nm
export OBJCOPY=${ORBISDEV}/bin/orbis-objcopy
export STRIP=${ORBISDEV}/bin/orbis-strip

export PORTLIBS_PREFIX=${PACBREW}/ps4/portlibs
export PKG_CONFIG_PATH=${PORTLIBS_PREFIX}/lib/pkgconfig
export PATH=${PORTLIBS_PREFIX}/bin:$PATH

export ARCH="--target=x86_64-scei-ps4"
export CFLAGS="${ARCH} -O2 -D__PS4__ -D__ORBIS__ -I${PORTLIBS_PREFIX}/include -isystem ${ORBISDEV} -isysroot ${ORBISDEV}"
export CXXFLAGS="${CFLAGS}"
export CPPFLAGS="${CFLAGS}"

if [ "$1" == "lib" ]; then
  export LIBS="-L${ORBISDEV}/lib -L${ORBISDEV}/usr/lib -L${PORTLIBS_PREFIX}/lib"
  export LDFLAGS="${ARCH} ${LIBS} -Wl,--gc-sections,--gc-keep-exported"
else
  export LIBS="-L${PORTLIBS_PREFIX}/lib -L${ORBISDEV}/lib -L${ORBISDEV}/usr/lib -lkernel_stub -lSceLibcInternal_stub"
  export LDFLAGS="${ORBISDEV}/usr/lib/crt0.o ${ARCH} ${LIBS} -T ${ORBISDEV}/usr/lib/linker.x -Wl,--dynamic-linker=/libexec/ld-elf.so.1 -Wl,--gc-sections -Wl,-z -Wl,max-page-size=0x4000 -Wl,-pie -Wl,--eh-frame-hdr"
fi
