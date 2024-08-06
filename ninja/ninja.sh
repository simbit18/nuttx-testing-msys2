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

ninja_brew() {
  if ! type ninja > /dev/null 2>&1; then
    echo "no ninja !!!"
    brew install ninja
  else
    echo "ok ninja !!!"
  fi

  command ninja --version

}
main() {
  mkdir -p "${WDTOOLS}"
  echo "#!/usr/bin/env sh" > "${WDTOOLS}"/env.sh
  
  mkdir -p "${WDTOOLS}"/homebrew
  export HOMEBREW_CACHE=${WDTOOLS}/homebrew
  echo "export HOMEBREW_CACHE=${WDTOOLS}/homebrew" >> "${WDTOOLS}"/env.sh
  
  oldpath=$(cd . && pwd -P)
  cd "${oldpath}"
  
  echo "PATH=${PATH}" >> "${WDTOOLS}"/env.sh
  echo "export PATH" >> "${WDTOOLS}"/env.sh
  source "${WDTOOLS}"/env.sh
  ninja_brew
  ninja --version
  
  ## ninja_brew

}
main