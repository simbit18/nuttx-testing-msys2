#!/bin/sh

set -e
set -o xtrace

WD=$(cd "$(dirname "$0")" && pwd)
WORKSPACE=$(cd "${WD}"/../ && pwd -P)

WDTOOLS=${WORKSPACE}/tools
EXTRA_PATH=

add_path() {
  PATH=$1:${PATH}
}

check_cmd() {
  command -v "$1" > /dev/null 2>&1
}

bloaty_test() {
  add_path "${WDTOOLS}"/bloaty/bin

  if [ ! -f "${WDTOOLS}/bloaty/bin/bloaty" ]; then
    git clone --branch main https://github.com/google/bloaty "${WDTOOLS}"/bloaty-src
    # git clone https://github.com/google/bloaty "${tools}"/bloaty-src
    mkdir -p "${WDTOOLS}"/bloaty
    cd "${WDTOOLS}"/bloaty-src
    cmake -B build/bloaty -D BLOATY_PREFER_SYSTEM_CAPSTONE=NO -D CMAKE_INSTALL_PREFIX="${WDTOOLS}"/bloaty
    cmake --build build/bloaty
    cmake --build build/bloaty --target install
    cd "${WDTOOLS}"
    rm -rf bloaty-src
    ls -a "${WDTOOLS}"/bloaty
    ls -a "${WDTOOLS}"/bloaty/bin
  fi
  if [ ! -f "${WDTOOLS}/bloaty/bin/bloaty" ]; then
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
  mkdir -p "${WDTOOLS}"
   echo "#!/usr/bin/env sh" > "${WDTOOLS}"/env.sh
  cd "${WDTOOLS}"
  bloaty_test
  echo "PATH=${PATH}" >> "${WDTOOLS}"/env.sh
  echo "export PATH" >> "${WDTOOLS}"/env.sh
  source "${WDTOOLS}"/env.sh
  ## bloaty_brew

}
main