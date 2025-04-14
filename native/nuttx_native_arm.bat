  @REM Copyright (C) 2025 by simbit18
 
  @echo off
  setlocal
    :: zip o tar.gz
    set archive=zip
    echo. Tools NuttX
    set work_dir=%~dp0
    :: Removes trailing backslash
    :: to enhance readability in the following steps
    set work_dir=%work_dir:~0,-1%
    set install_dir=%work_dir%\tools
    if not exist "%install_dir%" (
      mkdir %install_dir%
    )
    cd /D %install_dir%
    echo %install_dir%

    set win_tools_basefile=win-tools-v1.38.0
    set kconfig_basefile=kconfig-frontends-windows-mingw64
    set arm_basefile=arm-gnu-toolchain-13.2.Rel1-mingw-w64-i686-arm-none-eabi

    rem ======================== win_tools
    set PATH="%install_dir%\win-tools;%PATH%"
    if not exist "%install_dir%\win-tools\busybox.exe" (
      echo. download %win_tools_basefile%.%archive%
      curl -L https://github.com/simbit18/win-tools/releases/download/win-tools-v1.38.0/%win_tools_basefile%.%archive% -o %win_tools_basefile%.%archive%
      tar zxf %win_tools_basefile%.%archive%
      move /y %win_tools_basefile% "win-tools"
      if not ERRORLEVEL 0 goto error
      del /q /f "%install_dir%\%win_tools_basefile%.%archive%"
      if not ERRORLEVEL 0 goto error
    )
echo.
    rem ======================== kconfig_frontends
    set PATH="%install_dir%\kconfig-frontends\bin;%PATH%"
    if not exist "%install_dir%\kconfig-frontends\bin\kconfig-conf.exe" (
      echo. download %kconfig_basefile%.%archive%
      curl -L https://github.com/simbit18/kconfig-frontends-windows-mingw64/releases/download/kconfig-frontends-4.11.0/%kconfig_basefile%.%archive% -o %kconfig_basefile%.%archive%
      tar zxf %kconfig_basefile%.%archive%
      move /y %kconfig_basefile% "kconfig-frontends"
      if not ERRORLEVEL 0 goto error
      del /q /f "%install_dir%\%kconfig_basefile%.%archive%"
      if not ERRORLEVEL 0 goto error
    )
echo.
    rem ======================== ARM
    set PATH="%install_dir%\gcc-arm-none-eabi\bin;%PATH%"
    if not exist "%install_dir%\gcc-arm-none-eabi\bin\arm-none-eabi-gcc.exe" (
      echo. download %arm_basefile%.%archive%
      REM goto end
      curl -L https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/binrel/%arm_basefile%.%archive% -o %arm_basefile%.%archive%
      tar zxf %arm_basefile%.%archive%
      move /y %arm_basefile% "gcc-arm-none-eabi"
      if not ERRORLEVEL 0 goto error
      del /q /f "%install_dir%\%arm_basefile%.%archive%"
      if not ERRORLEVEL 0 goto error
      arm-none-eabi-gcc --version
    )
echo.

    set
    cd /D %work_dir%
echo //-------------------------------------------------------------------------//
echo // SUCCESS
echo //-------------------------------------------------------------------------//
goto end
REM Errors
:error
echo //-------------------------------------------------------------------------//
echo --- // Error downloading, installing, or testing the compiler ---
echo //-------------------------------------------------------------------------//
exit /B 1
goto end

:end
goto :EOF
pause
