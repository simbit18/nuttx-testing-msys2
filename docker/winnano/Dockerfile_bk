ARG IMAGE_OS_VERSION=ltsc2022
FROM mcr.microsoft.com/windows/servercore:${IMAGE_OS_VERSION} AS download

SHELL ["powershell", "-Command"]

# Retrieve msys2
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
        -Uri $('https://github.com/msys2/msys2-installer/releases/download/nightly-x86_64/msys2-base-x86_64-latest.sfx.exe') \
        -OutFile $('C:\Temp\msys2-base.exe') \
        -UseBasicParsing \ 
        -Verbose ; \
    \
    Start-Process \
        -FilePath $('C:\Temp\msys2-base.exe') \
        -ArgumentList '-y -oC:\Temp\' \
        -NoNewWindow \
        -Wait \
        -Verbose ; \
    \
    Remove-Item \
        -Path 'C:\Temp\msys2-base.exe' \
        -Verbose ;

FROM mcr.microsoft.com/windows/nanoserver:${IMAGE_OS_VERSION} AS build

COPY msvcp140.dll /Windows/System32/

COPY vcruntime140.dll /Windows/System32/

RUN dir windows\system32

COPY --from=download ["/temp/msys64", "/msys64"]

RUN SETX PATH "C:\msys64\usr\local\bin;C:\msys64\usr\bin;C:\msys64\bin;C:\msys64\usr\bin\site_perl;C:\msys64\usr\bin\vendor_perl;C:\msys64\usr\bin\core_perl;%PATH%"

# Test application
RUN \
    bash \
        --version

