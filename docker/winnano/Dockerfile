ARG 7ZIP_VERSION=1805
ARG IMAGE_OS_VERSION=ltsc2022
FROM mcr.microsoft.com/windows/servercore:${IMAGE_OS_VERSION} AS download

ARG 7ZIP_VERSION

#SHELL ["pwsh", "-Command"]
# SHELL ["powershell", "-Command"]

# Retrieve msys2
#RUN powershell -command \
#    Invoke-WebRequest #"https://github.com/msys2/msys2-installer/releases/download/nightly-x86_64/msys2-base-x86_64-latest.sfx.exe" -OutFile #"C:\\windows\\temp\\msys2-base.exe" && \
#    "C:\\windows\\temp\\msys2-base.exe" -y "-oC:\\windows\\temp\\"

RUN powershell -command \
    if(!(Test-Path -Path 'C:\Temp')) \
    { \
        New-Item \
            -Path 'C:\Temp' \
            -ItemType Directory \
            -Verbose ; \
    } ; \
    \
    Invoke-WebRequest \
        -Uri $('https://www.7-zip.org/a/7z' + $ENV:7ZIP_VERSION + '-x64.exe') \
        -OutFile $('C:\Temp\7z' + $ENV:7ZIP_VERSION + '-x64.exe') \
        -UseBasicParsing \ 
        -Verbose ; \
    \
    Start-Process \
        -FilePath $('C:\Temp\7z' + $ENV:7ZIP_VERSION + '-x64.exe') \
        -ArgumentList '/S' \
        -NoNewWindow \
        -Wait \
        -Verbose ; 

FROM mcr.microsoft.com/windows/nanoserver:${IMAGE_OS_VERSION} AS build

ARG 7ZIP_VERSION

COPY --from=download ["/Program Files/7-Zip", "/Program Files/7-Zip"]

RUN SETX PATH "%ProgramFiles%\7-Zip;%PATH%"

# Test application
RUN \
    7z \
        b