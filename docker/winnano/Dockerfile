ARG IMAGE_OS_VERSION=ltsc2022
FROM mcr.microsoft.com/windows/server:${IMAGE_OS_VERSION} AS build

RUN dir & dir Windows

# Test application
RUN \
    pwsh \
        -v

RUN pwsh -command Get-ChildItem -Path C:\ -Filter *.cab -Recurse -ErrorAction SilentlyContinue -Force
