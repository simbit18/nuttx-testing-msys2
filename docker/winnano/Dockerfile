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

FROM mcr.microsoft.com/windows/nanoserver:${IMAGE_OS_VERSION}

RUN dir & dir Windows
RUN dir windows\system32

COPY --from=download C:/Windows/system32/advapi32.dll C:/Windows/system32/advapi32.dll
COPY --from=download C:/Windows/system32/comctl32.dll C:/Windows/system32/comctl32.dll
COPY --from=download C:/Windows/system32/comdlg32.dll C:/Windows/system32/comdlg32.dll
COPY --from=download C:/Windows/system32/gdi32.dll C:/Windows/system32/gdi32.dll
COPY --from=download C:/Windows/system32/kernel32.dll C:/Windows/system32/kernel32.dll
COPY --from=download C:/Windows/system32/ole32.dll C:/Windows/system32/ole32.dll
COPY --from=download C:/Windows/system32/psapi.dll C:/Windows/system32/psapi.dll
COPY --from=download C:/Windows/system32/shell32.dll C:/Windows/system32/shell32.dll
COPY --from=download C:/Windows/system32/shlwapi.dll C:/Windows/system32/shlwapi.dll
COPY --from=download C:/Windows/system32/user32.dll C:/Windows/system32/user32.dll
COPY --from=download C:/Windows/system32/version.dll C:/Windows/system32/version.dll
COPY --from=download C:/Windows/system32/winmm.dll C:/Windows/system32/winmm.dll

COPY --from=download C:/Temp/msys64 C:/msys64

RUN dir windows\system32

RUN SETX PATH "C:\msys64\usr\local\bin;C:\msys64\usr\bin;C:\msys64\bin;C:\msys64\usr\bin\site_perl;C:\msys64\usr\bin\vendor_perl;C:\msys64\usr\bin\core_perl;%PATH%"
# Test application
RUN \
    bash \
        -version
