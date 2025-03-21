ARG IMAGE_OS_VERSION=ltsc2022
FROM mcr.microsoft.com/windows/nanoserver:${IMAGE_OS_VERSION}

RUN dir
RUN dir windows\system32

# https://devblogs.microsoft.com/dotnet/we-made-windows-server-core-container-images-40-smaller/
# Install msys2
RUN curl -fSLo msys2-base.exe https://github.com/msys2/msys2-installer/releases/download/nightly-x86_64/msys2-base-x86_64-latest.sfx.exe `
    && .\msys2-base.exe -y -oC:\Temp\ `
    && del .\ msys2-base.exe `
    && powershell Remove-Item -Force -Recurse ${Env:TEMP}\*

# Apply latest patch
#RUN curl -fSLo patch.msu 
# http://download.windowsupdate.com/c/msdownload/update/software/updt/2019/09/windows10.0-kb4515843-x64_181da0224818b03254ff48178c3cd7f73501c9db.msu `
#    && mkdir patch `
#    && expand patch.msu patch -F:* `
#    && del /F /Q patch.msu `
#    && DISM /Online /Quiet /Add-Package /PackagePath:C:\patch\Windows10.0-kb4515843-x64.cab `
#    && rmdir /S /Q patch

