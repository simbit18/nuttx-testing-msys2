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

bloaty_test() {
  add_path "${tools}"/bloaty/bin

  if [ ! -f "${tools}/bloaty/bin/bloaty" ]; then
    git clone --branch main https://github.com/google/bloaty "${tools}"/bloaty-src
    # git clone https://github.com/google/bloaty "${tools}"/bloaty-src
    mkdir -p "${tools}"/bloaty
    cd "${tools}"/bloaty-src
    cmake -B build/bloaty -D BLOATY_PREFER_SYSTEM_CAPSTONE=NO -D CMAKE_INSTALL_PREFIX="${tools}"/bloaty
    cmake --build build/bloaty
    cmake --build build/bloaty --target install
    cd "${tools}"
    rm -rf bloaty-src
    ls -a "${tools}"/bloaty
    ls -a "${tools}"/bloaty/bin
  fi
  if [ ! -f "${tools}/bloaty/bin/bloaty" ]; then
    echo "no bloaty !!!"
  fi

  command bloaty --version

}

bloaty_brew() {
  if ! type avr-gcc > /dev/null 2>&1; then
    echo "no bloaty !!!"
    brew install bloaty
  else
    echo "ok bloaty !!!"
  fi

  command bloaty --version

}
main() {
  mkdir -p "${tools}"
  cd "${tools}"
  bloaty_test
  ## bloaty_brew

}
main