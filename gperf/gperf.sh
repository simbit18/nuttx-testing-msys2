#!/bin/sh

set -e
set -o xtrace
osarch=$(uname -m)

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

arm_gcc_toolchain() {
  add_path "${WDTOOLS}"/gcc-arm-none-eabi/bin

  if [ ! -f "${WDTOOLS}/gcc-arm-none-eabi/bin/arm-none-eabi-gcc" ]; then
    local basefile
    basefile=arm-gnu-toolchain-13.2.rel1-darwin-x86_64-arm-none-eabi
    cd "${WDTOOLS}"
    curl -O -L -s https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/binrel/${basefile}.tar.xz
    xz -d ${basefile}.tar.xz
    tar xf ${basefile}.tar
    mv ${basefile} gcc-arm-none-eabi
    rm ${basefile}.tar
  fi

  command arm-none-eabi-gcc --version
}

binutils() {
  add_path "${WDTOOLS}"/bintools/bin

  if ! type objcopy > /dev/null 2>&1; then
    brew install binutils
    mkdir -p "${WDTOOLS}"/bintools/bin
    # It is possible we cached prebuilt but did brew install so recreate
    # symlink if it exists
    if [ "X$osarch" == "Xarm64" ]; then
      rm -f "${WDTOOLS}"/bintools/bin/objcopy
      ln -s /opt/homebrew/opt/binutils/bin/objcopy "${WDTOOLS}"/bintools/bin/objcopy
    else
      rm -f "${WDTOOLS}"/bintools/bin/objcopy
      ln -s /usr/local/opt/binutils/bin/objcopy "${WDTOOLS}"/bintools/bin/objcopy
    fi
  fi

  command objcopy --version
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

elf_toolchain() {
  if ! type x86_64-elf-gcc > /dev/null 2>&1; then
    brew install x86_64-elf-gcc
  fi

  command x86_64-elf-gcc --version
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

automake_brew() {
  if ! type automake > /dev/null 2>&1; then
    echo "no automake !!!"
    brew install automake
  else
    echo "ok automake !!!"
  fi

  command automake --version

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

python_tools() {
  # Python User Env
  export PIP_USER=yes
  export PYTHONUSERBASE=${WDTOOLS}/pylocal
  echo "export PIP_USER=yes" >> "${WDTOOLS}"/env.sh
  echo "export PYTHONUSERBASE=${WDTOOLS}/pylocal" >> "${WDTOOLS}"/env.sh
  add_path "${PYTHONUSERBASE}"/bin
  
  if [ "X$osarch" == "Xarm64" ]; then
    python3 -m venv --system-site-packages /opt/homebrew
  # else
  #   python3 -m venv --system-site-packages /usr/local
  fi
  
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
    construct \
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

main() {
  mkdir -p "${WDTOOLS}"
  echo "#!/usr/bin/env sh" > "${WDTOOLS}"/env.sh
  
  mkdir -p "${WDTOOLS}"/homebrew
  export HOMEBREW_CACHE=${WDTOOLS}/homebrew
  echo "export HOMEBREW_CACHE=${WDTOOLS}/homebrew" >> "${WDTOOLS}"/env.sh
  
  oldpath=$(cd . && pwd -P)
  cd "${oldpath}"
  which python3
  which brew
  which virtualenv
  arm_gcc_toolchain
  binutils
  gperf
  autoconf_brew
  # automake_brew
  elf_toolchain
  kconfig_frontends
  python_tools
  u_boot_tools
  util_linux
  echo "PATH=${PATH}" >> "${WDTOOLS}"/env.sh
  echo "export PATH" >> "${WDTOOLS}"/env.sh
  source "${WDTOOLS}"/env.sh
  # gperf --version

}
main