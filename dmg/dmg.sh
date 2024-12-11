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

 # minizinc_config_cmdline: export PATH=$PATH:$(pwd)/bin/MiniZincIDE.app/Contents/Resources
 # minizinc_cache_path: $(pwd)/bin/MiniZincIDE.app
 # minizinc_url: https://github.com/MiniZinc/MiniZincIDE/releases/download/2.8.5/MiniZincIDE-2.8.5-bundled.dmg
 # minizinc_downloaded_filepath: bin/minizinc.dmg
 # minizinc_install_cmdline: sudo hdiutil attach bin/minizinc.dmg; sudo cp -R /Volumes/MiniZinc*/MiniZincIDE.app bin/.
#download
# curl -o "${{ env.minizinc_downloaded_filepath }}" -L ${{ env.minizinc_url }}
# Install
# ${{ env.minizinc_install_cmdline }}
# Test
# ${{ env.minizinc_config_cmdline }}
# minizinc --version


arm_clang_toolchain() {
  add_path "${WDTOOLS}"/clang-arm-none-eabi/bin

  if [ ! -f "${WDTOOLS}/clang-arm-none-eabi/bin/clang" ]; then
    local basefile
    basefile=LLVMEmbeddedToolchainForArm-17.0.1-Darwin
    cd "${WDTOOLS}"
    # Download the latest ARM clang toolchain prebuilt by ARM
    curl -O -L -s https://github.com/ARM-software/LLVM-embedded-toolchain-for-Arm/releases/download/release-17.0.1/${basefile}.dmg
    mkdir -p "${WDTOOLS}"/clang-arm-none-eabi
    sudo hdiutil attach ${basefile}.dmg
    ls -a
    sudo cp -R /Volumes/${basefile}/${basefile} "${WDTOOLS}"/clang-arm-none-eabi
    ls -a "${WDTOOLS}"/clang-arm-none-eabi
    rm ${basefile}.dmg
  fi

  command clang --version
}

main() {
  mkdir -p "${WDTOOLS}"
  echo "#!/usr/bin/env sh" > "${WDTOOLS}"/env.sh
  
  mkdir -p "${WDTOOLS}"/homebrew
  export HOMEBREW_CACHE=${WDTOOLS}/homebrew
  echo "export HOMEBREW_CACHE=${WDTOOLS}/homebrew" >> "${WDTOOLS}"/env.sh
  
  oldpath=$(cd . && pwd -P)
  cd "${oldpath}"
  arm_clang_toolchain
  echo "PATH=${PATH}" >> "${WDTOOLS}"/env.sh
  echo "export PATH" >> "${WDTOOLS}"/env.sh
  source "${WDTOOLS}"/env.sh
  clang --version

}
main