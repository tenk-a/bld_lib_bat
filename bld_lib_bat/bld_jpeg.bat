@echo off
rem This batch-file license: boost software license version 1.0
setlocal
call libs_config.bat
cd ..

if not exist %CcMiscIncDir% mkdir %CcMiscIncDir%
if not exist %CcMiscLibDir% mkdir %CcMiscLibDir%

if not "%1"=="" set "CcLibJpegDir=%1"

if "%CcLibJpegDir%"=="" (
  for /f %%i in ('dir /b /on /ad jpeg*') do set CcLibJpegDir=%%i
)

if "%CcLibJpegDir%"=="" (
  echo ERROR: not found source directory
  goto END
)

if not exist %CcMiscIncDir%\jpeg mkdir %CcMiscIncDir%\jpeg
call :gen_header %CcLibJpegDir% >%CcMiscIncDir%\jpeg\jpeglib.h

set Arg=libcopy:%CD%\%CcMiscLibDir%
if "%CcNoRtStatic%"=="1" set Arg=%Arg% rtdll

cd %CcLibJpegDir%
call ..\bld_lib_bat\setcc.bat %CcName% x86
call ..\bld_lib_bat\bld1_jpeg.bat x86 %Arg%
if "%CcHasX64%"=="1" (
  call ..\bld_lib_bat\setcc.bat %CcName% x64
  call ..\bld_lib_bat\bld1_jpeg.bat x64 %Arg%
)
cd ..
goto :END


:gen_header
echo /// jpeglib.h wrapper (official version)
echo #pragma once
echo #include "../../%1/jpeglib.h"
echo #ifdef _MSC_VER
echo   #pragma comment(lib, "libjpeg.lib")
echo #endif
exit /b


:END
cd bld_lib_bat
endlocal
