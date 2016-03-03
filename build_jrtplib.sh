#!/bin/sh
# Written by Lim Jiunn Haur <jim@jh_lim.com>
# 
# Builds the JRTPLib library for Android

# export PATH="${NDK_ROOT}/toolchains/arm-linux-androideabi-4.4.3/prebuilt/darwin-x86/bin/:${PATH}"
export NDK_ROOT="/home/lor/tools/ndk"
SYS_ROOT="${NDK_ROOT}/platforms/android-L/arch-arm"
PREF="${NDK_ROOT}/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-"

C_FLAGS="	-lc \
			-lgcc \
			-lstdc++ -lsupc++ \
			-I${NDK_ROOT}/sources/cxx-stl/gnu-libstdc++/4.9/include \
			-I${NDK_ROOT}/sources/cxx-stl/gnu-libstdc++/4.9/libs/armeabi/include \
			-L../jthread-1.3.1/android-build/lib \
			-L${NDK_ROOT}/sources/cxx-stl/gnu-libstdc++/4.9/libs/armeabi"
OUT_DIR="`pwd`/android-build"

set -e

export CC="${PREF}gcc  --sysroot=${SYS_ROOT}"
export CXX="${PREF}g++  --sysroot=${SYS_ROOT}"
export LD="${PREF}ld  --sysroot=${SYS_ROOT}"
export CPP="${PREF}cpp  --sysroot=${SYS_ROOT}"
export AS="${PREF}as"
export OBJCOPY="${PREF}objcopy"
export OBJDUMP="${PREF}objdump"
export STRIP="${PREF}strip"
export RANLIB="${PREF}ranlib"
export CCLD="${PREF}gcc  --sysroot=${SYS_ROOT}"
export AR="${PREF}ar"

cmake	\
			-DCMAKE_SYSTEM_NAME="Generic" \
			-DCMAKE_CXX_FLAGS="${C_FLAGS}" \
			-DCMAKE_FIND_ROOT_PATH="${SYS_ROOT}" \
			-DJTHREAD_LIBRARIES="../jthread-1.3.1/android-build/lib" \
			-DCMAKE_PREFIX_PATH="../jthread-1.3.1/android-build" \
			-DCMAKE_INSTALL_PREFIX="${OUT_DIR}" .
		
make && \
make install

cd ${OUT_DIR}/lib && \
	${AR} -x libjrtplib.a && \
	${CXX} ${C_FLAGS} -shared -Wl,-soname,libjrtplib.so -o libjrtplib.so && \

exit 0
