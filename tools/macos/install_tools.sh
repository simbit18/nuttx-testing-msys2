#!/usr/bin/env sh
############################################################################
# nuttxspace/install_tools_rvvirt.sh
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

# macOS

set -e
set -o xtrace

CIWORKSPACE=$(cd "$(dirname "$0")" && pwd)
NUTTXTOOLS=${CIWORKSPACE}/tools

add_path() {
  PATH=$1:${PATH}
}

arm_gcc_toolchain() {
  add_path "${NUTTXTOOLS}"/gcc-arm-none-eabi/bin

  if [ ! -f "${NUTTXTOOLS}/gcc-arm-none-eabi/bin/arm-none-eabi-gcc" ]; then
    local basefile
    basefile=arm-gnu-toolchain-13.2.rel1-darwin-x86_64-arm-none-eabi
    cd "${NUTTXTOOLS}"
    wget --quiet https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/binrel/${basefile}.tar.xz
    xz -d ${basefile}.tar.xz
    tar xf ${basefile}.tar
    mv ${basefile} gcc-arm-none-eabi
    rm ${basefile}.tar
  fi

  command arm-none-eabi-gcc --version
}

arm64_gcc_toolchain() {
  add_path "${NUTTXTOOLS}"/gcc-aarch64-none-elf/bin

  if [ ! -f "${NUTTXTOOLS}/gcc-aarch64-none-elf/bin/aarch64-none-elf-gcc" ]; then
    local basefile
    basefile=arm-gnu-toolchain-13.2.Rel1-darwin-x86_64-aarch64-none-elf
    cd "${NUTTXTOOLS}"
    # Download the latest ARM64 GCC toolchain prebuilt by ARM
    wget --quiet https://developer.arm.com/-/media/Files/downloads/gnu/13.2.Rel1/binrel/${basefile}.tar.xz
    xz -d ${basefile}.tar.xz
    tar xf ${basefile}.tar
    mv ${basefile} gcc-aarch64-none-elf
    rm ${basefile}.tar
  fi

  command aarch64-none-elf-gcc --version
}

binutils() {
  mkdir -p "${NUTTXTOOLS}"/bintools/bin
  add_path "${NUTTXTOOLS}"/bintools/bin

  if ! type objcopy > /dev/null 2>&1; then
    brew install binutils
    # It is possible we cached prebuilt but did brew install so recreate
    # symlink if it exists
    rm -f "${NUTTXTOOLS}"/bintools/bin/objcopy
    ln -s /usr/local/opt/binutils/bin/objcopy "${NUTTXTOOLS}"/bintools/bin/objcopy
  fi

  command objcopy --version
}

elf_toolchain() {
  if ! type x86_64-elf-gcc > /dev/null 2>&1; then
    brew install x86_64-elf-gcc
  fi

  command x86_64-elf-gcc --version
}

gen_romfs() {
  if ! type genromfs > /dev/null 2>&1; then
    brew tap PX4/px4
    brew install genromfs
  fi
}

gperf() {
  add_path "${NUTTXTOOLS}"/gperf/bin

  if [ ! -f "${NUTTXTOOLS}/gperf/bin/gperf" ]; then
    local basefile
    basefile=gperf-3.1

    cd "${NUTTXTOOLS}"
    wget --quiet http://ftp.gnu.org/pub/gnu/gperf/${basefile}.tar.gz
    tar zxf ${basefile}.tar.gz
    cd "${NUTTXTOOLS}"/${basefile}
    ./configure --prefix="${NUTTXTOOLS}"/gperf; make; make install
    cd "${NUTTXTOOLS}"
    rm -rf ${basefile}; rm ${basefile}.tar.gz
  fi

  command gperf --version
}

kconfig_frontends() {
  add_path "${NUTTXTOOLS}"/kconfig-frontends/bin

  if [ ! -f "${NUTTXTOOLS}/kconfig-frontends/bin/kconfig-conf" ]; then
    git clone https://bitbucket.org/nuttx/tools.git "${NUTTXTOOLS}"/nuttx-tools
    cd "${NUTTXTOOLS}"/nuttx-tools/kconfig-frontends
    ./configure --prefix="${NUTTXTOOLS}"/kconfig-frontends \
      --disable-kconfig --disable-nconf --disable-qconf \
      --disable-gconf --disable-mconf --disable-static \
      --disable-shared --disable-L10n
    # Avoid "aclocal/automake missing" errors
    touch aclocal.m4 Makefile.in
    make install
    cd "${NUTTXTOOLS}"
    rm -rf nuttx-tools
  fi
}

ninja_brew() {
  if ! type ninja > /dev/null 2>&1; then
    brew install ninja
  fi

  command ninja --version
}

python_tools() {
  # Python User Env
  export PIP_USER=yes
  export PYTHONUSERBASE=${NUTTXTOOLS}/pylocal
  echo "export PIP_USER=yes" >> "${NUTTXTOOLS}"/env.sh
  echo "export PYTHONUSERBASE=${NUTTXTOOLS}/pylocal" >> "${NUTTXTOOLS}"/env.sh
  add_path "${PYTHONUSERBASE}"/bin

  # workaround for Cython issue
  # https://github.com/yaml/pyyaml/pull/702#issuecomment-1638930830
  pip3 install "Cython<3.0"
  git clone https://github.com/yaml/pyyaml.git && \
  cd pyyaml && \
  git checkout release/5.4.1 && \
  sed -i.bak 's/Cython/Cython<3.0/g' pyproject.toml && \
  python setup.py sdist && \
  pip3 install --pre dist/PyYAML-5.4.1.tar.gz
  cd ..
  rm -rf pyyaml

  pip3 install \
    cmake-format \
    cvt2utf \
    cxxfilt \
    esptool==4.8.dev4 \
    imgtool==1.9.0 \
    kconfiglib \
    pexpect==4.8.0 \
    pyelftools \
    pyserial==3.5 \
    pytest==6.2.5 \
    pytest-json==0.4.0 \
    pytest-ordering==0.6 \
    pytest-repeat==0.9.1
}

riscv_gcc_toolchain() {
  add_path "${NUTTXTOOLS}"/riscv-none-elf-gcc/bin

  if [ ! -f "${NUTTXTOOLS}/riscv-none-elf-gcc/bin/riscv-none-elf-gcc" ]; then
    local basefile
    basefile=xpack-riscv-none-elf-gcc-13.2.0-2-darwin-x64
    cd "${NUTTXTOOLS}"
    # Download the latest RISCV GCC toolchain prebuilt by xPack
    wget --quiet https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/download/v13.2.0-2/${basefile}.tar.gz
    tar zxf ${basefile}.tar.gz
    mv xpack-riscv-none-elf-gcc-13.2.0-2 riscv-none-elf-gcc
    rm ${basefile}.tar.gz
  fi
  command riscv-none-elf-gcc --version
}

rust() {
  if ! type rustc > /dev/null 2>&1; then
    brew install rust
  fi

  command rustc --version
}

u_boot_tools() {
  if ! type mkimage > /dev/null 2>&1; then
    brew install u-boot-tools
  fi
}

util_linux() {
  if ! type flock > /dev/null 2>&1; then
    brew tap discoteq/discoteq
    brew install flock
  fi

  command flock --version
}

install_build_tools() {
  mkdir -p "${NUTTXTOOLS}"
  echo "#!/usr/bin/env sh" > "${NUTTXTOOLS}"/env.sh
install="arm_gcc_toolchain arm64_gcc_toolchain elf_toolchain gen_romfs gperf kconfig_frontends ninja_brew python_tools riscv_gcc_toolchain rust u_boot_tools util_linux "

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
