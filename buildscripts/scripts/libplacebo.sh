#!/bin/bash -e

. ../../include/depinfo.sh
. ../../include/path.sh

build=_build$ndk_suffix

if [ "$1" == "build" ]; then
	true
elif [ "$1" == "clean" ]; then
	rm -rf $build
	exit 0
else
	exit 255
fi

unset CC CXX # meson wants these unset

meson setup $build --cross-file "$prefix_dir"/crossfile.txt \
	--default-library=static \
	-Dvulkan=disabled \
	-Ddemos=false

ninja -C $build -j$cores
DESTDIR="$prefix_dir" ninja -C $build install

# Workaround for Meson C++ linking bug: add -lc++ to pkg-config Libs
sed -i'.original' -e 's/Libs:/Libs: -lc++/' "$prefix_dir/lib/pkgconfig/libplacebo.pc"
