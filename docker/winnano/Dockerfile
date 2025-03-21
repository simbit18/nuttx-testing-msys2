ARG IMAGE_OS_VERSION=ltsc2022

###############################################################################
# Base image that should be used to prepare tools from nuttx-tools
###############################################################################
FROM mcr.microsoft.com/windows/servercore:${IMAGE_OS_VERSION} AS nuttx-tools

# SHELL ["powershell", "-Command"]
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# RUN mkdir /tools
RUN \
    if(!(Test-Path -Path 'C:\tools')) \
    { \
        New-Item \
            -Path 'C:\tools' \
            -ItemType Directory \
            -Verbose ; \
    } ;
# RUN dir windows\system32

WORKDIR "C:\\tools"

# RUN mkdir -p /tools/nuttx-tools

###############################################################################
# Build image for tool required by ARM builds
###############################################################################
FROM nuttx-tools AS nuttx-toolchain-arm

RUN \
    if(!(Test-Path -Path 'C:\\tools\\gcc-arm-none-eabi')) \
    { \
        New-Item \
            -Path 'C:\\tools\\gcc-arm-none-eabi' \
            -ItemType Directory \
            -Verbose ; \
    } ; \
    \
    Invoke-WebRequest \
        -Uri $('https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/binrel/arm-gnu-toolchain-13.2.Rel1-mingw-w64-i686-arm-none-eabi.zip') \
        -OutFile $('C:\\tools\\rm-gnu-toolchain-13.2.Rel1-mingw-w64-i686-arm-none-eabi.zip') \
        -UseBasicParsing \ 
        -Verbose ; \
    \
    Expand-Archive \
        -Path "C:\\tools\\rm-gnu-toolchain-13.2.Rel1-mingw-w64-i686-arm-none-eabi.zip" ;

RUN dir "C:\\tools\\gcc-arm-none-eabi"

RUN dir "C:\\tools\\rm-gnu-toolchain-13.2.Rel1-mingw-w64-i686-arm-none-eabi"

RUN \ 
    Move-Item \
        -Path "C:\\tools\\arm-gnu-toolchain-13.2.Rel1-mingw-w64-i686-arm-none-eabi\\arm-gnu-toolchain-13.2.Rel1-mingw-w64-i686-arm-none-eabi" \
        -Destination 'gcc-arm-none-eabi' \
        -Verbose ;



RUN \
    Remove-Item \
        'arm-gnu-toolchain-13.2.Rel1-mingw-w64-i686-arm-none-eabi*' \
        -Force ;

FROM mcr.microsoft.com/windows/nanoserver:${IMAGE_OS_VERSION} AS build

LABEL \
    org.label-schema.name="NanoServer.NuttX" \
    org.label-schema.description="This image is a NuttX tools on NanoServer image." \
    org.label-schema.version="1.0.0" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.vendor="simbit18" \
    org.label-schema.url="https://test.com" \
    org.label-schema.maintainer.name="simbit18" \
    org.label-schema.vcs-url="https://github.com/simbit18"\
    org.label-schema.docker.cmd="docker run --name $CONTAINER -t -d docker-nano-nuttx:last" \
    org.label-schema.docker.cmd.test="docker exec $CONTAINER mysql --version" \
    org.label-schema.docker.cmd.debug="docker exec -it $CONTAINER powershell"

CMD ["powershell"]
