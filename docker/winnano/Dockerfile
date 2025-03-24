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
# Build image for tool required by win tools
###############################################################################
FROM nuttx-tools AS win-tools

RUN \
    if(!(Test-Path -Path 'C:\\tools\\win-tools')) \
    { \
        New-Item \
            -Path 'C:\\tools\\win-tools' \
            -ItemType Directory \
            -Verbose ; \
    } ; \
    \
    Invoke-WebRequest \
        -Uri $('https://github.com/simbit18/win-tools/releases/download/win-tools-v1.38.0/win-tools-v1.38.0.zip') \
        -OutFile $('C:\\tools\\win-tools-v1.38.0.zip') \
        -UseBasicParsing \ 
        -Verbose ; \
    \
    Expand-Archive \
        -Path "C:\\tools\\win-tools-v1.38.0.zip" ;

RUN dir "C:\\tools\\win-tools"

RUN dir "C:\\tools\\win-tools-v1.38.0"

RUN \ 
    Move-Item \
        -Path "C:\\tools\\win-tools-v1.38.0\\win-tools" \
        -Destination 'win-tools' \
        -Verbose ;

RUN \
    Remove-Item \
        'win-tools-v1.38.0*' \
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

# RUN dir windows\system32

# WORKDIR "C:\\tools"

# Pull in the tools we just built for nuttx

# win-tools
COPY --from=win-tools ["C:/tools/win-tools", "C:/tools/win-tools"]

# In order to set system PATH, ContainerAdministrator must be used
USER ContainerAdministrator

RUN SETX /M PATH "C:\tools\win-tools;%PATH%"

USER ContainerUser

RUN dir tools & dir tools\win-tools

# Test application
RUN busybox --list

CMD ["powershell"]
