#!/bin/bash

# toolchain
b ps4-toolchain/binutils
b ps4-toolchain/clang
b ps4-toolchain/headers
b ps4-toolchain/libgen
b ps4-toolchain/libcxx
b ps4-toolchain/linker
b ps4-toolchain/toolchain-vars
b ps4-toolchain/pkg-config

# portlibs
b ps4-portlibs/zlib
b ps4-portlibs/libpng
b ps4-portlibs/liborbis
b ps4-portlibs/liborbisGl
b ps4-portlibs/liborbisGl2
