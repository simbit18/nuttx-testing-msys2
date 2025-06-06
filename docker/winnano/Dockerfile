ARG IMAGE_OS_VERSION=ltsc2022

###############################################################################
# Base image that should be used to prepare tools from nuttx-tools
###############################################################################
FROM mcr.microsoft.com/windows/servercore:${IMAGE_OS_VERSION} AS nuttx-tools

# SHELL ["powershell", "-Command"]
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN \
    if(!(Test-Path -Path 'C:\Temp')) \
    { \
        New-Item \
            -Path 'C:\Temp' \
            -ItemType Directory \
            -Verbose ; \
    } ; \
    \
    Invoke-WebRequest \
        -Uri $('https://www.7-zip.org/a/7z2409-x64.exe') \
        -OutFile $('C:\Temp\7z2409-x64.exe') \
        -UseBasicParsing \ 
        -Verbose ; \
    \
    Start-Process \
        -FilePath $('C:\Temp\7z2409-x64.exe') \
        -ArgumentList '/S' \
        -NoNewWindow \
        -Wait \
        -Verbose ; \
    \
    Set-ItemProperty \
        -Path 'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment' \
        -Name 'Path' \
        -Value $('C:\Program Files\7-Zip;' + $ENV:Path) \
        -Verbose ;

# Test application
RUN \
    7z \
        b

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

WORKDIR "C:\tools"

# RUN mkdir -p /tools/nuttx-tools

###############################################################################
# Build image for tool required by .NET SDK
###############################################################################

FROM nuttx-tools AS net-sdk

RUN \
        # Retrieve .NET SDK \
        $sdk_version = '8.0.407'; \
        Invoke-WebRequest -OutFile dotnet.zip https://builds.dotnet.microsoft.com/dotnet/Sdk/$sdk_version/dotnet-sdk-$sdk_version-win-x64.zip; \
        $dotnet_sha512 = 'c36431c5f6fc2b4fc6ed983b33f4ace2b3d9062afafe83e4a17f8e58745100f1714938e62529d3011cc02b4ce5c63db9c9cddf438008aa6e5b4f77507772acb2'; \
        if ((Get-FileHash dotnet.zip -Algorithm sha512).Hash -ne $dotnet_sha512) { \
            Write-Host 'CHECKSUM VERIFICATION FAILED!'; \
            exit 1; \
        }; \
        mkdir dotnet; \
        tar -oxzf dotnet.zip -C dotnet; \
        Remove-Item -Force dotnet.zip; 


###############################################################################
# Build image for tool required by win tools
###############################################################################
FROM nuttx-tools AS win-tools

RUN \
    Invoke-WebRequest \
        -Uri $('https://github.com/simbit18/win-tools/releases/download/win-tools-v1.38.0/win-tools-v1.38.0.zip') \
        -OutFile $('C:\tools\win-tools-v1.38.0.zip') \
        -UseBasicParsing \ 
        -Verbose ; \
    \
    Expand-Archive \
        -Path "C:\tools\win-tools-v1.38.0.zip" ;

# RUN dir "C:\tools\win-tools"

RUN dir "C:\tools\win-tools-v1.38.0"

RUN \ 
    Move-Item \
        -Path "C:\tools\win-tools-v1.38.0\win-tools" \
        -Destination 'win-tools' \
        -Verbose ;

RUN \
    Remove-Item \
        'win-tools-v1.38.0*' \
        -Force ;

RUN dir "C:\tools\win-tools"

###############################################################################
# Build image for tool required by kconfig-frontends
###############################################################################
FROM nuttx-tools AS kconfig-frontends-tools

RUN \
    Invoke-WebRequest \
        -Uri $('https://github.com/simbit18/kconfig-frontends-windows-mingw64/releases/download/kconfig-frontends-4.11.0/kconfig-frontends-windows-mingw64.zip') \
        -OutFile $('C:\tools\kconfig-frontends-windows-mingw64.zip') \
        -UseBasicParsing \ 
        -Verbose ; \
    \
    Expand-Archive \
        -Path "C:\tools\kconfig-frontends-windows-mingw64.zip" ;

RUN dir "C:\tools\kconfig-frontends-windows-mingw64"

RUN \ 
    Move-Item \
        -Path "C:\tools\kconfig-frontends-windows-mingw64\kconfig-frontends-windows-mingw64" \
        -Destination 'kconfig-frontends' \
        -Verbose ;

RUN \
    Remove-Item \
        'kconfig-frontends-windows-mingw64*' \
        -Force ;

RUN dir "C:\tools\kconfig-frontends"


###############################################################################
# Build image for tool required by winlibs-mingw64
###############################################################################

FROM nuttx-tools AS winlibs-mingw64

RUN \
    Invoke-WebRequest \
        -Uri $('https://github.com/brechtsanders/winlibs_mingw/releases/download/13.2.0posix-18.1.5-11.0.1-msvcrt-r8/winlibs-x86_64-posix-seh-gcc-13.2.0-mingw-w64msvcrt-11.0.1-r8.zip') \
        -OutFile $('C:\tools\winlibs-x86_64-posix-seh-gcc-13.2.0-mingw-w64msvcrt-11.0.1-r8.zip') \
        -UseBasicParsing \ 
        -Verbose ; \
    \
    Expand-Archive \
        -Path "C:\tools\winlibs-x86_64-posix-seh-gcc-13.2.0-mingw-w64msvcrt-11.0.1-r8.zip" ; \

#RUN dir "C:\tools\winlibs-x86_64-posix-seh-gcc-13.2.0-mingw-w64msvcrt-11.0.1-r8"

# RUN \ 
    Move-Item \
        -Path "C:\tools\winlibs-x86_64-posix-seh-gcc-13.2.0-mingw-w64msvcrt-11.0.1-r8\mingw64" \
        -Destination 'winlibs-mingw64' \
        -Verbose ; \

# RUN \
    Remove-Item \
        'winlibs-x86_64-posix-seh-gcc-13.2.0-mingw-w64msvcrt-11.0.1-r8*' \
        -Force ;

# RUN dir "C:\tools\winlibs-mingw64"

###############################################################################
# Build image for tool required by ARM builds
###############################################################################
FROM nuttx-tools AS nuttx-toolchain-arm

RUN \
    Invoke-WebRequest \
        -Uri $('https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/binrel/arm-gnu-toolchain-13.2.Rel1-mingw-w64-i686-arm-none-eabi.zip') \
        -OutFile $('C:\tools\arm-gnu-toolchain-13.2.Rel1-mingw-w64-i686-arm-none-eabi.zip') \
        -UseBasicParsing \ 
        -Verbose ; \
    \
    Expand-Archive \
        -Path "C:\tools\arm-gnu-toolchain-13.2.Rel1-mingw-w64-i686-arm-none-eabi.zip" ;

RUN dir "C:\tools\arm-gnu-toolchain-13.2.Rel1-mingw-w64-i686-arm-none-eabi"

RUN \ 
    Move-Item \
        -Path "C:\tools\arm-gnu-toolchain-13.2.Rel1-mingw-w64-i686-arm-none-eabi\arm-gnu-toolchain-13.2.Rel1-mingw-w64-i686-arm-none-eabi" \
        -Destination 'gcc-arm-none-eabi' \
        -Verbose ;

RUN \
    Remove-Item \
        'arm-gnu-toolchain-13.2.Rel1-mingw-w64-i686-arm-none-eabi*' \
        -Force ;

RUN dir "C:\tools\gcc-arm-none-eabi"


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

COPY --from=net-sdk ["/tools/dotnet", "/Program Files/dotnet"]


# Pull in the tools we just built for nuttx
# In order to set system PATH, ContainerAdministrator must be used
USER ContainerAdministrator

# win-tools
COPY --from=win-tools ["C:/tools/win-tools", "C:/tools/win-tools"]
RUN SETX /M PATH "C:\tools\win-tools;%PATH%"

# RUN dir tools & dir tools\win-tools

# Test application
RUN busybox --list


# kconfig-frontends
COPY --from=kconfig-frontends-tools ["C:/tools/kconfig-frontends", "C:/tools/kconfig-frontends"]
RUN SETX /M PATH "C:\tools\kconfig-frontends\bin;%PATH%"

RUN dir tools & dir tools\kconfig-frontends

# winlibs-mingw64
COPY --from=winlibs-mingw64 ["C:/tools/winlibs-mingw64", "C:/tools/winlibs-mingw64"]

RUN SETX /M PATH "C:\tools\winlibs-mingw64\bin;%PATH%"

# Test application
RUN gcc --version

# RUN cmake --help

# nuttx-toolchain-arm
COPY --from=nuttx-toolchain-arm ["C:/tools/gcc-arm-none-eabi", "C:/tools/gcc-arm-none-eabi"]

RUN SETX /M PATH "C:\tools\gcc-arm-none-eabi\bin;%PATH%"

# Test application
RUN  arm-none-eabi-gcc --version

USER ContainerUser

CMD ["powershell"]
