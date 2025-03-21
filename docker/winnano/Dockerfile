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

WORKDIR tools

# RUN mkdir -p /tools/nuttx-tools



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
