#!/usr/bin/env bash

# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

# MSYS2

set -e
set -o xtrace

WD=$(cd "$(dirname "$0")" && pwd)
WORKSPACE=$(cd "${WD}"/../ && pwd -P)

tools=${WORKSPACE}/tools
EXTRA_PATH=

function add_path {
  PATH=$1:${PATH}
  EXTRA_PATH=$1:${EXTRA_PATH}
}

usage() {
    cat <<EOF
rustup-init 1.26.0 (577bf51ae 2023-04-05)
The installer for rustup

USAGE:
    rustup-init [OPTIONS]

OPTIONS:
    -v, --verbose
            Enable verbose output

    -q, --quiet
            Disable progress output

    -y
            Disable confirmation prompt.

        --default-host <default-host>
            Choose a default host triple

        --default-toolchain <default-toolchain>
            Choose a default toolchain to install. Use 'none' to not install any toolchains at all

        --profile <profile>
            [default: default] [possible values: minimal, default, complete]

    -c, --component <components>...
            Component name to also install

    -t, --target <targets>...
            Target name to also install

        --no-update-default-toolchain
            Don't update any existing default toolchain after install

        --no-modify-path
            Don't configure the PATH environment variable

    -h, --help
            Print help information

    -V, --version
            Print version information
EOF
}

check_cmd() {
    command -v "$1" > /dev/null 2>&1
}


function rust {
  add_path "${tools}"/rust/cargo/bin
  # Configuring the PATH environment variable
  export CARGO_HOME=${tools}/rust/cargo
  export RUSTUP_HOME=${tools}/rust/rustup
  if ! type rustc &> /dev/null; then
    mkdir -p "${tools}"/rust
    # Install Rust target x86_64-pc-windows-gnu
    ./rustup-init.exe -y --default-host x86_64-pc-windows-gnu --no-modify-path
    # Install targets supported from NuttX
    $CARGO_HOME/bin/rustup target add thumbv6m-none-eabi
    $CARGO_HOME/bin/rustup target add thumbv7m-none-eabi
  fi
  command rustc --version
}

main() {
  mkdir -p "${tools}"
  cd "${tools}"
  if check_cmd curl; then
    curl -O -L -s https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-gnu/rustup-init.exe
  elif check_cmd wget; then
    wget --quiet https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-gnu/rustup-init.exe
  else
    echo "no curl or wget ?" # to be used in error message of need_cmd
  fi
  rust
  
  pip3 install --root-user-action=ignore --no-cache-dir cffi pyOpenSSL wheel cryptography  esptool==4.5.1

}
main