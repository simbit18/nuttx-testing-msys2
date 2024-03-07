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
  if type -p ccache > /dev/null 2>&1; then
    command ccache --version
  else
    ccache -s
  fi
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
  export MSYS=winsymlinks:nativestrict
  ln -sf "$(which ccache)" "${tools}"/ccache/bin/cc
  ln -sf "$(which ccache)" "${tools}"/ccache/bin/c++
  ln -sf "$(which ccache)" "${tools}"/ccache/bin/gcc
  ln -sf "$(which ccache)" "${tools}"/ccache/bin/g++
  # cp "$(which ccache)" "${tools}"/ccache/bin/cc
  # cp "$(which ccache)" "${tools}"/ccache/bin/c++
  # cp "$(which ccache)" "${tools}"/ccache/bin/gcc
  # cp "$(which ccache)" "${tools}"/ccache/bin/g++
}




main() {
  mkdir -p "${tools}"
  cd "${tools}"
  ccache_test

}
main