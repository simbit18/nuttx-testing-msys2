FROM debian:bookworm AS build

# Install WINE build dependencies
RUN sed -i 's/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/debian.sources
RUN apt update && \
    DEBIAN_FRONTEND="noninteractive" apt-get build-dep --install-recommends -y wine && \
    # debian does not pull in i686 mingw (needed for building "experimental wow64" support)
    DEBIAN_FRONTEND="noninteractive" apt-get install -y gcc-mingw-w64-i686 && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y git && \
    rm -rf /var/lib/apt/lists/*

# Build and install patched WINE (see https://github.com/msys2/MSYS2-packages/issues/682)
RUN git clone --filter=tree:0 https://gitlab.winehq.org/jhol/wine.git /tmp/winesrc && \
    cd /tmp/winesrc && \
    # https://gitlab.winehq.org/jhol/wine/-/commits/msys2-hacks-18
    git checkout 90e376d085e78ed4c5e91480f354866637f53e1c && \
    ./configure --disable-tests --enable-win64 --with-mingw --enable-archs=x86_64,i386 && \
    make -j $(nproc) && \
    env DESTDIR=/wine make -j $(nproc) install && \
    rm -rf /tmp/winesrc && \
    # Clean things up
    find /wine -type f -exec strip --strip-all {} \; && \
    rm -Rf /wine/usr/local/include

# Install MSYS2
RUN apt update && apt install -y zstd curl
RUN mkdir -p /tmp/msys64
RUN curl --fail -L 'https://github.com/msys2/msys2-installer/releases/download/nightly-x86_64/msys2-base-x86_64-latest.tar.zst' | tar -x --zstd -C  /tmp/

FROM debian:bookworm

# Copy over wine and install the runtime deps
RUN apt update \
    && apt install -y --no-install-recommends xvfb wine64 xauth \
    && apt remove -y wine64 libwine \
    && rm -rf /var/lib/apt/lists/*
COPY --from=build /wine /
RUN ldconfig

# XXX: otherwise things hang
RUN winecfg

# Copy over MSYS2
COPY --from=build /tmp/msys64 /root/.wine/drive_c/msys64

# XXX: Signature validation is too slow, so disable it for now
# To keep the impact of this change lower, we only allow the main mirror
RUN sed -i /root/.wine/drive_c/msys64/etc/pacman.conf -e 's/SigLevel    = Required/SigLevel = Never/g'
RUN echo 'Server = https://repo.msys2.org/msys/$arch/' > /root/.wine/drive_c/msys64/etc/pacman.d/mirrorlist.msys
RUN echo 'Server = https://repo.msys2.org/mingw/$repo/' > /root/.wine/drive_c/msys64/etc/pacman.d/mirrorlist.mingw

# Not strictly necessary, let's skip it for now
RUN sed -i 's/--refresh-keys/--version/g' '/root/.wine/drive_c/msys64/etc/post-install/07-pacman-key.post'

# Disable space checks to speed up package installation
RUN sed -i /root/.wine/drive_c/msys64/etc/pacman.conf -e 's/^CheckSpace/#CheckSpace/g'

# COPY ./msys2 /usr/bin/msys2
# RUN chmod +x /usr/bin/msys2

# WINEDEBUG="-all"
ENV WINEPATH="C:\\msys64\\usr\\bin"
ENV MSYSTEM="MSYS"
# MSYSTEM="${MSYSTEM:-UCRT64}" xvfb-run -a wine bash.exe -l "$@"

# Run for the first time
RUN msys2 -c " "

WORKDIR /root/.wine/drive_c/msys64/home/root
CMD [ "xvfb-run -a wine bash.exe" ]
#CMD ["msys2"]
