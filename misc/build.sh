#!/bin/bash

# Abstruct: build autotools style package to your favorite directory
#
# Usage:
#  $ build
#  $ build --without-hoge --enable-foo
#  $ env PREFIX=/tmp/local build
#
# depend: https://github.com/shoichikaji/File-DirDiff

note() { echo -e "\e[33m$@\e[m" >&2; }
die()  { echo -e "\e[31m$@\e[m" >&2; exit 1; }

PREFIX=${PREFIX-$HOME/local}
DEFAULT_OPTION=${DEFAULT_OPTION---prefix=$PREFIX --disable-shared}
export CFLAGS="-O3 -fPIC"
export CPPFLAGS=-I$PREFIX/include
export LDFLAGS=-L$PREFIX/lib
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig
export PATH=$PREFIX/bin:$PATH
export PKGCONFIG=$PREFIX/bin/pkg-config
export PKG_CONFIG=$PREFIX/bin/pkg-config

if [ $# -ne 0 ] && [ $1 = "--" ]; then
  shift
  CMD="./configure $@ && make install"
else
  CMD="./configure $DEFAULT_OPTION $@ && make install"
fi

note "---> $CMD"
dirdiff $HOME/local bash -c "$CMD" || die !!! FAIL !!!
