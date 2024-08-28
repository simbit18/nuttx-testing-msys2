ARG IMAGE_OS_VERSION=ltsc2022
FROM mcr.microsoft.com/windows/nanoserver:${IMAGE_OS_VERSION} AS build

RUN dir & dir Windows

SHELL ["powershell", "-Command"]

RUN \
    \
    Get-ChildItem \
        -Path 'C:\' \
        -Filter '*.cab' \
        -Recurse \
        -Verbose ;

# RUN powershell -command Get-ChildItem -Path C:\ -Filter *.cab -Recurse -ErrorAction SilentlyContinue -Force

RUN dism.exe /online /add-package /packagepath:C:\packages\Microsoft-OneCore-ReverseForwarders-Package.cab & del C:\packages\Microsoft-OneCore-ReverseForwarders-Package.cab
# RUN dism /Online /Add-Package /PackagePath:C:\packages\Microsoft-OneCore-ReverseForwarders-Package.cab & del C:\packages\Microsoft-OneCore-ReverseForwarders-Package.cab

RUN dir windows\system32

COPY --from=download ["/temp/msys64", "/msys64"]

# RUN SETX PATH "C:\msys64\usr\local\bin;C:\msys64\usr\bin;C:\msys64\bin;C:\msys64\usr\bin\site_perl;C:\msys64\usr\bin\vendor_perl;C:\msys64\usr\bin\core_perl;%PATH%"

# Test application
#RUN \
#    bash \
#        --version
