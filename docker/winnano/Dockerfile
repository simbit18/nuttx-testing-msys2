# escape=`

ARG IMAGE_OS_VERSION=ltsc2022
FROM mcr.microsoft.com/windows/servercore:${IMAGE_OS_VERSION} AS installer

# Retrieve msys2
RUN powershell -command \
    Invoke-WebRequest "https://github.com/msys2/msys2-installer/releases/download/nightly-x86_64/msys2-base-x86_64-latest.sfx.exe" -OutFile "C:\\windows\\temp\\msys2-base.exe" && \
    C:\\windows\\temp\\msys2-base.exe -y -oC:\\windows\\temp\\ && \
    Remove-Item -Force C:\\windows\\temp\\msys2-base.exe


# Runtime image
FROM mcr.microsoft.com/windows/nanoserver:${IMAGE_OS_VERSION}

ENV DOWNLOAD_DIR="C:\download" \
    BUILD_DIR="C:\build" \
    TARGET_DIR="C:\target" \
    SEVEN_ZIP_VERSION="22.01" \
    SEVEN_ZIP_DOWNLOAD_URL="http://www.7-zip.org/a" \
    SEVEN_ZIP_HOME="C:\Program Files\7-Zip" \
    GIT_VERSION="2.37.2.2" \
    CMAKE_VERSION="3.24.1" \
    CMAKE_URL="https://github.com/Kitware/CMake/releases/download" \
    CMAKE_HOME="C:\cmake" \
    MSYS2_URL="http://repo.msys2.org/distrib" \
    MSYS2_TARGET="x86_64" \
    MSYS2_VERSION="20220603" \
    MSYS_HOME="C:\msys64" \
    STRAWBERRY_PERL_VERSION="5.32.1.1" \
    STRAWBERRY_PERL_URL="https://strawberryperl.com/download" \
    STRAWBERRY_PERL_HOME="C:\Perl" \
    PYTHON_URL="https://www.python.org/ftp/python" \
    PYTHON3_VERSION="3.10.6" \
    PYTHON3_HOME="C:\Python3" \
    PYTHON2_VERSION="2.7.18" \
    PYTHON2_HOME="C:\Python2" \
    NINJA_VERSION="1.11.0" \
    NINJA_URL="https://github.com/ninja-build/ninja/releases/download" \
    NINJA_HOME="C:\ninja"

RUN mkdir "%DOWNLOAD_DIR%" && \
    mkdir "%BUILD_DIR%" && \
    mkdir "%TARGET_DIR%"

# In order to set system PATH, ContainerAdministrator must be used
USER ContainerAdministrator
RUN setx /M PATH "%PATH%;C:\msys64\usr\local\bin;C:\msys64\usr\bin;C:\msys64\bin;C:\msys64\usr\bin\site_perl;C:\msys64\usr\bin\vendor_perl;C:\msys64\usr\bin\core_perl"
USER ContainerUser

COPY --from=installer ["/windows/system32/netapi32.dll", "/windows/system32/netapi32.dll"]
COPY --from=installer ["/windows/temp/msys64", "/msys64"]

RUN bash -l -c "pacman -Syuu --needed --noconfirm --noprogressbar" && \
    bash -l -c "pacman -Syu --needed --noconfirm --noprogressbar"
#    bash -l -c "rm -fr /C/Users/ContainerUser/* /var/cache/pacman/pkg/*"
	
RUN mklink /J C:\\msys64\\home\\ContainerUser C:\\Users\\ContainerUser && \
    setx HOME "C:\msys64\home\ContainerUser"


# Install required packages
RUN      bash -l -c " \
		pacman -S --needed --noconfirm \
			base-devel \
			gcc \
			gperf \
			git \
			python3 \
			ncurses-devel \
			unzip \
			tio \
			zlib-devel \
			cmake \
			ninja \
                        python-pip \
                        vim && \
		rm -r /var/cache/pacman/pkg/* \
          "
# WARNING: Running pip as the 'root' user can result in broken permissions and conflicting behaviour with the system package manager.
# It is recommended to use a virtual environment instead: https://pip.pypa.io/warnings/venv
ENV PIP_ROOT_USER_ACTION=ignore

# Install Python 3 option
RUN bash -l -c " \
         pip3 install \
         pyelftools \
         cxxfilt \
	 kconfiglib \
     "
# Install kconfig-frontends
RUN bash -l -c " \
         curl -L https://bitbucket.org/nuttx/tools/get/master.tar.gz -o nuttx-tools.tar.gz \
	 && mkdir nuttx-tools \
         && tar xvzf nuttx-tools.tar.gz --strip-components=1 -C nuttx-tools \
	 && cd nuttx-tools/kconfig-frontends \
	 && ./configure --prefix=/opt/nuttxenv/usr --enable-mconf --disable-gconf --disable-qconf --disable-shared --disable-nconf \
	 && make install \
     "     
# Install genromfs
RUN bash -l -c " \
         cd nuttx-tools \
	 && tar xzf genromfs-0.5.2.tar.gz \
         && cd genromfs-0.5.2 \
         && make install PREFIX=/opt/nuttxenv \
     "	
 		
# Copy NXTOOL GENROMFS and clean source files
RUN bash -l -c " \
	cp /opt/nuttxenv/usr/bin/kconfig-conf.exe /usr/bin \
	&& cp /opt/nuttxenv/usr/bin/kconfig-mconf.exe /usr/bin \
	&& cp /opt/nuttxenv/usr/bin/kconfig-tweak /usr/bin \
	&& cp /opt/nuttxenv/usr/bin/genromfs.exe /usr/bin \
        && rm -rf nuttx-tools genromfs-0.5.2 \
      "
ENV MSYSTEM=MSYS
WORKDIR C:\\msys64\\home\\ContainerUser\\
CMD ["bash", "-l"]

ARG image_version="0"
ARG image_revision="1"

LABEL name="simbit18/windows--nano-base" \
    version="${image_version}" \
    revision="${image_revision}" \
    description="Nano Server base image for builders on Windows"
