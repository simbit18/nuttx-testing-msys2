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
  add_path "${NUTTXTOOLS}"/bloaty/bin

  if [ ! -f "${NUTTXTOOLS}/bloaty/bin/bloaty" ]; then
    git clone --branch main https://github.com/google/bloaty "${NUTTXTOOLS}"/bloaty-src
    mkdir -p "${NUTTXTOOLS}"/bloaty
    cd "${NUTTXTOOLS}"/bloaty-src
    cmake -B build/bloaty -D BLOATY_PREFER_SYSTEM_CAPSTONE=NO -D CMAKE_INSTALL_PREFIX="${NUTTXTOOLS}"/bloaty
    cmake --build build/bloaty
    cmake --build build/bloaty --target install
    cd "${NUTTXTOOLS}"
    rm -rf bloaty-src
    ls -a "${NUTTXTOOLS}"/bloaty
  fi

  command bloaty --version
  
}

main() {
  mkdir -p "${tools}"
  cd "${tools}"
  bloaty_test

}
main