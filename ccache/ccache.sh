#!/bin/sh

set -e
set -o xtrace

WD=$(cd "$(dirname "$0")" && pwd)
WORKSPACE=$(cd "${WD}"/../ && pwd -P)

tools=${WORKSPACE}/tools
EXTRA_PATH=

add_path() {
  PATH=$1:${PATH}
  EXTRA_PATH=$1:${EXTRA_PATH}
}

check_cmd() {
    command -v "$1" > /dev/null 2>&1
}

ccache_test() {
  add_path "${tools}"/ccache/bin
  # Configuring the PATH environment variable
  # export CARGO_HOME=${tools}/rust/cargo
  export CCACHE_DIR=${tools}/ccache/bin
  if ! type ccache > /dev/null 2>&1; then
    pacman -S --noconfirm --needed ccache
  fi
  ccache -s
  setup_links
  gcc ${WD}/exception_setjmp.c -o exception_setjmp
  ccache -s
  ccache -p
  command ccache --version
  
}

setup_links() {
  # Configure ccache
  mkdir -p "${tools}"/ccache/bin/
  # ok local
  # export MSYS=winsymlinks:lnk
  # export MSYS=winsymlinks:nativestrict
  # MSYS=winsymlinks:nativestrict ln -sf "$(which ccache)" "${tools}"/ccache/bin/cc
  # MSYS=winsymlinks:nativestrict ln -sf "$(which ccache)" "${tools}"/ccache/bin/c++
  # MSYS=winsymlinks:nativestrict ln -sf "$(which ccache)" "${tools}"/ccache/bin/gcc
  # ln -s "$(which ccache)" "${tools}"/ccache/bin/g++
  # ln -s "$(which ccache)" "${tools}"/ccache/bin/cc
  # ln -s "$(which ccache)" "${tools}"/ccache/bin/c++
  # ln -s "$(which ccache)" "${tools}"/ccache/bin/gcc
  # ln -s "$(which ccache)" "${tools}"/ccache/bin/g++
  # cp -a "$(which ccache)" "${tools}"/ccache/bin/cc
  # cp -a "$(which ccache)" "${tools}"/ccache/bin/c++
  # cp -a "$(which ccache)" "${tools}"/ccache/bin/gcc
  # cp -a "$(which ccache)" "${tools}"/ccache/bin/g++
}




main() {
  mkdir -p "${tools}"
  cd "${tools}"
  ccache_test

}
main