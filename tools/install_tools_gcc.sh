#!/usr/bin/env sh
############################################################################
# nuttxspace/install_tools_gcc.sh
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.  The
# ASF licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.
#
############################################################################

# MSYS2
# (Always use the MSYS2 shell launcher ->  C:\msys64\msys2.exe)

set -e
set -o xtrace

CIWORKSPACE=$(cd "$(dirname "$0")" && pwd)
NUTTXTOOLS=${CIWORKSPACE}/tools

add_path() {
  PATH=$1:${PATH}
}

gcc_toolchain() {
  add_path "${NUTTXTOOLS}"/winlibs/bin

  if [ ! -f "${NUTTXTOOLS}/winlibs/bin/gcc" ]; then
    local basefile
    basefile=winlibs-x86_64-posix-seh-gcc-13.3.0-mingw-w64ucrt-11.0.1-r1
    cd "${NUTTXTOOLS}"
    # Download the latest GCC toolchain prebuilt by winlibs
    curl -O -L https://github.com/brechtsanders/winlibs_mingw/releases/download/13.3.0posix-11.0.1-ucrt-r1/${basefile}.zip
    unzip -qo ${basefile}.zip
    mv mingw64 winlibs
    rm ${basefile}.zip
  fi

  command gcc --version
}

gen_romfs() {
  add_path "${NUTTXTOOLS}"/genromfs/usr/bin

  if ! type genromfs > /dev/null 2>&1; then
    git clone https://bitbucket.org/nuttx/tools.git "${NUTTXTOOLS}"/nuttx-tools
    cd "${NUTTXTOOLS}"/nuttx-tools
    tar zxf genromfs-0.5.2.tar.gz
    cd genromfs-0.5.2
    make install PREFIX="${NUTTXTOOLS}"/genromfs
    cd "${NUTTXTOOLS}"
    rm -rf nuttx-tools
  fi
}

kconfig_frontends() {
  add_path "${NUTTXTOOLS}"/kconfig-frontends/bin

  if [ ! -f "${NUTTXTOOLS}/kconfig-frontends/bin/kconfig-conf" ]; then
    git clone https://bitbucket.org/nuttx/tools.git "${NUTTXTOOLS}"/nuttx-tools
    cd "${NUTTXTOOLS}"/nuttx-tools/kconfig-frontends
    ./configure --prefix="${NUTTXTOOLS}"/kconfig-frontends \
      --enable-mconf --disable-kconfig --disable-nconf --disable-qconf \
      --disable-gconf --disable-static \
      --disable-shared --disable-L10n
    # Avoid "aclocal/automake missing" errors
    touch aclocal.m4 Makefile.in
    make install
    cd "${NUTTXTOOLS}"
    rm -rf nuttx-tools
  fi
}


install_build_tools() {
  mkdir -p "${NUTTXTOOLS}"
  echo "#!/usr/bin/env sh" > "${NUTTXTOOLS}"/env.sh

  install="gcc_toolchain kconfig_frontends"

  oldpath=$(cd . && pwd -P)
  for func in ${install}; do
    ${func}
  done
  cd "${oldpath}"

  echo "PATH=${PATH}" >> "${NUTTXTOOLS}"/env.sh
  echo "export PATH" >> "${NUTTXTOOLS}"/env.sh
}

mkdir -p "${NUTTXTOOLS}"

install_build_tools
