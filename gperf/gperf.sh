#!/bin/sh

set -e
set -o xtrace

WD=$(cd "$(dirname "$0")" && pwd)
WORKSPACE=$(cd "${WD}"/../../ && pwd -P)

WDTOOLS=${WORKSPACE}/tools
EXTRA_PATH=

add_path() {
  PATH=$1:${PATH}
}

check_cmd() {
  command -v "$1" > /dev/null 2>&1
}

kconfig_frontends() {
  add_path "${WDTOOLS}"/kconfig-frontends/bin

  if [ ! -f "${WDTOOLS}/kconfig-frontends/bin/kconfig-conf" ]; then
    git clone --depth 1 https://bitbucket.org/nuttx/tools.git "${WDTOOLS}"/nuttx-tools
    cd "${WDTOOLS}"/nuttx-tools/kconfig-frontends
    ./configure --prefix="${WDTOOLS}"/kconfig-frontends \
      --disable-kconfig --disable-nconf --disable-qconf \
      --disable-gconf --disable-mconf --disable-static \
      --disable-shared --disable-L10n
    # Avoid "aclocal/automake missing" errors
    touch aclocal.m4 Makefile.in
    make install
    cd "${WDTOOLS}"
    rm -rf nuttx-tools
  fi
}

gperf() {
  add_path "${WDTOOLS}"/gperf/bin

  if [ ! -f "${WDTOOLS}/gperf/bin/gperf" ]; then
    local basefile
    basefile=gperf-3.1

    cd "${WDTOOLS}"
    curl -O -L -s http://ftp.gnu.org/pub/gnu/gperf/${basefile}.tar.gz
    tar zxf ${basefile}.tar.gz
    cd "${WDTOOLS}"/${basefile}
    ./configure --prefix="${WDTOOLS}"/gperf; make; make install
    cd "${WDTOOLS}"
    rm -rf ${basefile}; rm ${basefile}.tar.gz
  fi

  command gperf --version
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
    cmake -B build/bloaty -GNinja -D BLOATY_PREFER_SYSTEM_CAPSTONE=NO -D CMAKE_INSTALL_PREFIX="${WDTOOLS}"/bloaty
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
  if ! type bloaty > /dev/null 2>&1; then
    echo "no bloaty !!!"
    brew install bloaty
  else
    echo "ok bloaty !!!"
  fi

  command bloaty --version

}

ninja_brew() {
  if ! type ninja > /dev/null 2>&1; then
    echo "no ninja !!!"
    brew install ninja
  else
    echo "ok ninja !!!"
  fi

  command ninja --version

}

autoconf_brew() {
  if ! type autoconf > /dev/null 2>&1; then
    echo "no autoconf !!!"
    brew install autoconf
  else
    echo "ok autoconf !!!"
  fi

  command autoconf --version

}
main() {
  mkdir -p "${WDTOOLS}"
  echo "#!/usr/bin/env sh" > "${WDTOOLS}"/env.sh
  
  mkdir -p "${WDTOOLS}"/homebrew
  export HOMEBREW_CACHE=${WDTOOLS}/homebrew
  echo "export HOMEBREW_CACHE=${WDTOOLS}/homebrew" >> "${WDTOOLS}"/env.sh
  
  oldpath=$(cd . && pwd -P)
  cd "${oldpath}"
  gperf
  autoconf_brew
  kconfig_frontends
  echo "PATH=${PATH}" >> "${WDTOOLS}"/env.sh
  echo "export PATH" >> "${WDTOOLS}"/env.sh
  source "${WDTOOLS}"/env.sh
  gperf --version

}
main