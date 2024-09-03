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


FROM alpine:3.20.2 AS download-base
# NOTE WE ARE NOT REMOVEING APT CACHE.
# This should only be used for download that artifacts will be copied from
RUN apk --no-cache --update add \
  git \
  curl \
  tar \
  gzip \
  bzip2 \
  xz

###############################################################################
# Base image that should be used to prepare arch build images
###############################################################################
FROM download-base AS nuttx-toolchain-base

RUN mkdir -p /tools
WORKDIR /tools

###############################################################################
# Build image for tool required by ARM builds
###############################################################################
FROM nuttx-toolchain-base AS nuttx-toolchain-arm
# Download the latest ARM clang toolchain prebuilt by ARM
RUN mkdir -p clang-arm-none-eabi && \
  curl -s -L  "https://github.com/ARM-software/LLVM-embedded-toolchain-for-Arm/releases/download/release-17.0.1/LLVMEmbeddedToolchainForArm-17.0.1-Linux-x86_64.tar.xz" \
  | tar -C clang-arm-none-eabi --strip-components 1 -xJ

# Download the latest ARM GCC toolchain prebuilt by ARM
RUN mkdir -p gcc-arm-none-eabi && \
  curl -s -L  "https://developer.arm.com/-/media/Files/downloads/gnu/13.2.Rel1/binrel/arm-gnu-toolchain-13.2.Rel1-x86_64-arm-none-eabi.tar.xz" \
  | tar -C gcc-arm-none-eabi --strip-components 1 -xJ

###############################################################################
# Build image for tool required by AVR32 builds
###############################################################################
FROM nuttx-toolchain-base AS nuttx-toolchain-avr32
# Download the prebuilt AVR32 GCC toolchain
# RUN apt-get update -qq && DEBIAN_FRONTEND="noninteractive" apt-get install -y -qq \
#  git
# Clone Main Repository
RUN mkdir -p gcc-avr32-gnu && \
  git clone --depth 1 https://github.com/ramangopalan/avr32-gnu-toolchain-linux_x86 gcc-avr32-gnu


FROM alpine:3.20.2
RUN apk --no-cache --update add \
  bash \
  bash-completion
# Used to generate symbol table files

RUN mkdir -p /tools
WORKDIR /tools



# ARM clang toolchain
COPY --from=nuttx-toolchain-arm /tools/clang-arm-none-eabi/ clang-arm-none-eabi/
# RUN cp /usr/bin/clang-extdef-mapping-10 clang-arm-none-eabi/bin/clang-extdef-mapping
ENV PATH="/tools/clang-arm-none-eabi/bin:$PATH"

# ARM GCC toolchain
COPY --from=nuttx-toolchain-arm /tools/gcc-arm-none-eabi/ gcc-arm-none-eabi/
ENV PATH="/tools/gcc-arm-none-eabi/bin:$PATH"

# AVR32 toolchain
COPY --from=nuttx-toolchain-avr32 /tools/gcc-avr32-gnu/ gcc-avr32-gnu/
ENV PATH="/tools/gcc-avr32-gnu/bin:$PATH"

CMD [ "/bin/bash" ]
