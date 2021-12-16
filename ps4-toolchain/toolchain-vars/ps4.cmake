cmake_minimum_required(VERSION 3.7)

###################################################################

if(NOT DEFINED ENV{ORBISDEV})
	set(ORBISDEV /opt/pacbrew/ps4/toolchain)
else()
	set(ORBISDEV $ENV{ORBISDEV})
endif()

list(APPEND CMAKE_MODULE_PATH "${ORBISDEV}/cmake")

set(PS4 TRUE)

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR "x86_64")
set(CMAKE_CROSSCOMPILING 1)

set(CMAKE_ASM_COMPILER ${ORBISDEV}/bin/orbis-as     CACHE PATH "")
set(CMAKE_C_COMPILER   ${ORBISDEV}/bin/clang        CACHE PATH "")
set(CMAKE_CXX_COMPILER ${ORBISDEV}/bin/clang++      CACHE PATH "")
set(CMAKE_LINKER       ${ORBISDEV}/bin/orbis-ld     CACHE PATH "")
set(CMAKE_AR           ${ORBISDEV}/bin/orbis-ar     CACHE PATH "")
set(CMAKE_RANLIB       ${ORBISDEV}/bin/orbis-ranlib CACHE PATH "")
set(CMAKE_STRIP        ${ORBISDEV}/bin/orbis-strip  CACHE PATH "")

set(CMAKE_LIBRARY_ARCHITECTURE x86_64 CACHE INTERNAL "abi")

set(CMAKE_FIND_ROOT_PATH
	${ORBISDEV}
	${ORBISDEV}/usr
)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

set(BUILD_SHARED_LIBS OFF CACHE INTERNAL "Shared libs not available")

###################################################################

set(PS4_ARCH_SETTINGS "--target=x86_64-scei-ps4")
set(PS4_COMMON_FLAGS  "${PS4_ARCH_SETTINGS} -D__PS4__ -D__ORBIS__ -I${ORBISDEV}/usr/include -isystem ${ORBISDEV} -isysroot ${ORBISDEV}")
set(PS4_LIB_DIRS      "-L${ORBISDEV}/lib -L${ORBISDEV}/usr/lib")

set(CMAKE_C_FLAGS_INIT   "${PS4_COMMON_FLAGS}")
set(CMAKE_CXX_FLAGS_INIT "${PS4_COMMON_FLAGS} -I${ORBISDEV}/usr/include/c++/v1")
set(CMAKE_ASM_FLAGS_INIT "${PS4_COMMON_FLAGS}")

set(CMAKE_EXE_LINKER_FLAGS_INIT "${PS4_ARCH_SETTINGS} ${PS4_LIB_DIRS} -Wl,--gc-sections,--gc-keep-exported")

# Start find_package in config mode
set(CMAKE_FIND_PACKAGE_PREFER_CONFIG TRUE)

# Set pkg-config for the same
find_program(PKG_CONFIG_EXECUTABLE NAMES orbis-pkg-config HINTS "${ORBISDEV}/usr/bin")
if (NOT PKG_CONFIG_EXECUTABLE)
	message(WARNING "Could not find orbis-pkg-config: try installing ps4-pkg-config")
endif()
