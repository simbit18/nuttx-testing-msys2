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
    cd "${WDTOOLS}"/bloaty-src
    # Due to issues with latest MacOS versions use pinned commit.
    # https://github.com/google/bloaty/pull/326
    git checkout 52948c107c8f81045e7f9223ec02706b19cfa882
    mkdir -p "${WDTOOLS}"/bloaty
    # cmake -D BLOATY_PREFER_SYSTEM_CAPSTONE=NO -DCMAKE_SYSTEM_PREFIX_PATH="${WDTOOLS}"/bloaty
    # make install -j 4
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
  
  mkdir -p "${NUTTXTOOLS}"/homebrew
  export HOMEBREW_CACHE=${NUTTXTOOLS}/homebrew
  echo "export HOMEBREW_CACHE=${NUTTXTOOLS}/homebrew" >> "${NUTTXTOOLS}"/env.sh
  
  oldpath=$(cd . && pwd -P)
  cd "${oldpath}"
  bloaty_test
  echo "PATH=${PATH}" >> "${WDTOOLS}"/env.sh
  echo "export PATH" >> "${WDTOOLS}"/env.sh
  source "${WDTOOLS}"/env.sh
  ## bloaty_brew

}
main