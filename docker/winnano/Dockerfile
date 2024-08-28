ARG IMAGE_OS_VERSION=ltsc2022
FROM mcr.microsoft.com/windows/nanoserver:${IMAGE_OS_VERSION} AS build

RUN dir & dir Windows

ARG PWSH_VERSION=6.0.2

SHELL ["powershell", "-Command"]

RUN \
    if(!(Test-Path -Path 'C:\Temp')) \
    { \
        New-Item \
            -Path 'C:\Temp' \
            -ItemType Directory \
            -Verbose | Out-Null ; \
    } ; \
    \
    Invoke-WebRequest \
        -Uri $('https://github.com/PowerShell/PowerShell/releases/download/v' + $ENV:PWSH_VERSION + '/PowerShell-' + $ENV:PWSH_VERSION + '-win-x64.zip') \
        -OutFile $('C:\Temp\PowerShell-' + $ENV:PWSH_VERSION + '-win-x64.zip') \
        -UseBasicParsing \ 
        -Verbose ; \
    \
    Expand-Archive \
        -Path $('C:\Temp\PowerShell-' + $ENV:PWSH_VERSION + '-win-x64.zip') \
        -DestinationPath $(Join-Path -Path "$ENV:ProgramFiles\PowerShell" -ChildPath $ENV:PWSH_VERSION) \
        -Verbose ; \
    \
    Set-ItemProperty \
        -Path 'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment' \
        -Name 'Path' \
        -Value $($ENV:Path + ';' + $(Join-Path -Path "$ENV:ProgramFiles\PowerShell" -ChildPath $ENV:PWSH_VERSION)) \
        -Verbose ;

# Test application
RUN \
    pwsh \
        -v

# Remove temporary items from the build image
RUN \
    Remove-Item \
        -Path 'C:\Temp' \
        -Recurse \
        -Verbose ;

CMD ["pwsh"]

RUN pwsh -command Get-ChildItem -Path C:\ -Filter *.cab -Recurse -ErrorAction SilentlyContinue -Force

RUN dism.exe /online /add-package /packagepath:C:\packages\Microsoft-OneCore-ReverseForwarders-Package.cab & del C:\packages\Microsoft-OneCore-ReverseForwarders-Package.cab
# RUN dism /Online /Add-Package /PackagePath:C:\packages\Microsoft-OneCore-ReverseForwarders-Package.cab & del C:\packages\Microsoft-OneCore-ReverseForwarders-Package.cab

RUN dir windows\system32

COPY --from=download ["/temp/msys64", "/msys64"]

# RUN SETX PATH "C:\msys64\usr\local\bin;C:\msys64\usr\bin;C:\msys64\bin;C:\msys64\usr\bin\site_perl;C:\msys64\usr\bin\vendor_perl;C:\msys64\usr\bin\core_perl;%PATH%"

# Test application
#RUN \
#    bash \
#        --version
