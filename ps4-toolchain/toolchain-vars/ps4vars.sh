#!/usr/bin/env bash
export PACBREW=/opt/pacbrew
export ORBISDEV=${PACBREW}/ps4/toolchain
export PS4SDK=${PACBREW}/ps4/toolchain

#export PORTLIBS_ROOT=${PACBREW}/ps4/portlibs
#export PATH=${ORBISDEV}/bin:$PATH
#export TOOL_PREFIX=orbis-
export CC=${ORBISDEV}/bin/clang
export CXX=${ORBISDEV}/bin/clang++
export AS=${ORBISDEV}/bin/clang
export LD=${ORBISDEV}/bin/orbis-ld
export AR=${ORBISDEV}/bin/orbis-ar
export RANLIB=${ORBISDEV}/bin/orbis-ranlib

export PORTLIBS_PREFIX=${PACBREW}/ps4/portlibs
export PATH=${PORTLIBS_PREFIX}/bin:$PATH

export ARCH="--target=x86_64-scei-ps4"
export CFLAGS="${ARCH} -O2 -D__PS4__ -D__ORBIS__ -I${PORTLIBS_PREFIX}/include -isystem ${ORBISDEV}"
export CXXFLAGS="${CFLAGS}"
export CPPFLAGS="${CFLAGS}"

export LDFLAGS="${ARCH} -L${PORTLIBS_PREFIX}/lib -L${ORBISDEV}/lib -L${ORBISDEV}/usr/lib"
export LDFLAGS="${LDFLAGS} $(ORBISDEV)/usr/lib/crt0.o -T $(ORBISDEV)/usr/lib/linker.x --dynamic-linker=/libexec/ld-elf.so.1 --gc-sections -z max-page-size=0x4000  -pie --eh-frame-hdr"
#export LIBS=""
