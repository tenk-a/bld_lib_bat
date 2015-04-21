@echo off
rem This batch-file license: boost software license version 1.0
setlocal
call libs_config.bat
cd ..

if not exist %CcMiscIncDir% mkdir %CcMiscIncDir%
if not exist %CcMiscLibDir% mkdir %CcMiscLibDir%

if not "%1"=="" set "CcLibJpegTurboDir=%1"

if "%CcLibJpegTurboDir%"=="" (
  for /f %%i in ('dir /b /on /ad libjpeg-turbo*') do set CcLibJpegTurboDir=%%i
)

if "%CcLibJpegTurboDir%"=="" (
  echo ERROR: not found source directory
  goto END
)

if not exist %CcMiscIncDir%\jpeg-turbo mkdir %CcMiscIncDir%\jpeg-turbo
call :gen_header_turbojpeg %CcLibJpegTurboDir% >%CcMiscIncDir%\jpeg-turbo\turbojpeg.h
call :gen_header_jpeglib   %CcLibJpegTurboDir% >%CcMiscIncDir%\jpeg-turbo\jpeglib.h

set Arg=libcopy:%CD%\%CcMiscLibDir%

cd %CcLibJpegTurboDir%
call ..\bld_lib_bat\setcc.bat %CcName% x86
call ..\bld_lib_bat\bld1_libjpeg-turbo.bat x86 %Arg%
if "%CcHasX64%"=="1" (
  call ..\bld_lib_bat\setcc.bat %CcName% x64
  call ..\bld_lib_bat\bld1_libjpeg-turbo.bat x64 %Arg%
)
cd ..
goto END

:gen_header_turbojpeg
echo /// turbojpeg.h wrapper
echo #pragma once
echo #include "../../%1/turbojpeg.h"
echo #ifdef _MSC_VER
echo  #ifdef DLLDEFINE
echo   #pragma comment(lib, "turbojpeg.lib")
echo  #else
echo   #pragma comment(lib, "turbojpeg-static.lib")
echo  #endif
echo #endif
exit /b

:gen_header_jpeglib
echo /// jpeglib.h wrapper (turbo version)
echo #pragma once
echo #include "../../%1/jpeglib.h"
echo #ifdef _MSC_VER
echo   #pragma comment(lib, "jpeg-static.lib")
echo #endif
exit /b

:END
cd bld_lib_bat
endlocal
