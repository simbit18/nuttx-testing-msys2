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

CMD ["powershell"]
