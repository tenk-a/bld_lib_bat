@echo off
rem This batch-file license: boost software license version 1.0
setlocal
call libs_config.bat
cd ..

if not exist %CcMiscIncDir% mkdir %CcMiscIncDir%
if not exist %CcMiscLibDir% mkdir %CcMiscLibDir%

if not "%1"=="" set "CcLibTiffDir=%1"

if "%CcLibTiffDir%"=="" (
  for /f %%i in ('dir /b /on /ad tiff*') do set CcLibTiffDir=%%i
)

if "%CcLibTiffDir%"=="" (
  echo ERROR: not found source directory
  goto END
)

if "%CcLibJpegDir%"=="" (
  for /f %%i in ('dir /b /on /ad jpeg*') do set CcLibJpegDir=%%i
)

if not exist %CcMiscIncDir%\tiff mkdir %CcMiscIncDir%\tiff
call :gen_header tiffio.h     %CcLibTiffDir% >%CcMiscIncDir%\tiff\tiffio.h
call :gen_header tiffio.hxx   %CcLibTiffDir% >%CcMiscIncDir%\tiff\tiffio.hxx
rem call :gen_header tif_config.h %CcLibTiffDir% >%CcMiscIncDir%\tiff\tif_config.h

set Arg=libcopy:%CD%\%CcMiscLibDir% zlibinc:%CD%\%CcMiscIncDir% zliblib:%CD%\%CcMiscLibDir% jpeginc:%CD%\%CcLibJpegDir% jpeglib:%CD%\%CcMiscLibDir%
if "%CcNoRtStatic%"=="1" set Arg=%Arg% rtdll

cd %CcLibTiffDir%
call ..\bld_lib_bat\setcc.bat %CcName% x86
call ..\bld_lib_bat\bld1_tiff.bat x86 %Arg%
if "%CcHasX64%"=="1" (
  call ..\bld_lib_bat\setcc.bat %CcName% x64
  call ..\bld_lib_bat\bld1_tiff.bat x64 %Arg%
)
cd ..
goto :END

:gen_header
echo /// %1 wrapper
echo #pragma once
echo #include "../../%2/libtiff/%1"
echo #ifdef _MSC_VER
echo   #pragma comment(lib, "libtiff.lib")
echo #endif
exit /b

:END
cd bld_lib_bat
endlocal
