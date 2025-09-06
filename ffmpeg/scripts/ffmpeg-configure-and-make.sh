#!/bin/bash

time (
if [ "$(<configure sha256sum)" != 'c19f2856f7b355db3ef1fc5d9de85f31b6c62da7fca71c197be7988523d482b1  -' ]; then
  exec 1>&2
  echo "Could not find configure script. Not in the correct directory: ${PWD}"
  exit 1
fi
BIN_DIR="$PWD/.bin"
BUILD_DIR="$PWD/.build"
#            --enable-libfdk-aac \
#            --enable-libsvtav1 \
#            --enable-libvpx \
#            --enable-libx265 \
#            --enable-nonfree \
env PATH="$BIN_DIR:$PATH" PKG_CONFIG_PATH="$BUILD_DIR/lib/pkgconfig" \
./configure --prefix="$BUILD_DIR" \
            --pkg-config-flags="--static" \
            --extra-cflags="-I$BUILD_DIR/include" \
            --extra-ldflags="-L$BUILD_DIR/lib" \
            --extra-libs="-lpthread -lm" \
            --ld="g++" \
            --bindir="$BIN_DIR" \
            --enable-gpl \
            --enable-gnutls \
            --enable-libaom \
            --enable-libass \
            --enable-libfreetype \
            --enable-libmp3lame \
            --enable-libopus \
            --enable-libdav1d \
            --enable-libvorbis \
            --enable-libx264 \
&& env PATH="$BIN_DIR:$PATH" make \
&& make install \
&& hash -r
)
