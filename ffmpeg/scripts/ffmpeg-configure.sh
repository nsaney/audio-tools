#!/bin/bash

time (
if [ ! -x configure ] || [ ! -f Makefile ] || [ ! -d .git ] || [ ! -x ffbuild/version.sh ]; then
  exec 1>&2
  echo "This does not seem to be an ffmpeg directory: ${PWD}"
  exit 1
fi
set -x
# adapted from https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu#FFmpeg
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
)
