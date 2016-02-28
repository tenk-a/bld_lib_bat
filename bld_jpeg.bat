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

rem call :gen_header jpeglib.h ../../%CcLibJpegDir% libjpeg.lib %CcMiscIncDir%\jpeg
call :gen_header jpeglib.h ../%CcLibJpegDir% libjpeg.lib %CcMiscIncDir%

set Arg=libcopy:%CD%\%CcMiscLibDir%
if "%CcNoRtStatic%"=="1" set Arg=%Arg% rtdll

cd %CcLibJpegDir%
call ..\bld_lib_bat\setcc.bat %CcName% %CcLibArchX86%
call ..\bld_lib_bat\bld1_jpeg.bat %CcLibArchX86% %Arg%
if "%CcHasX64%"=="1" (
  call ..\bld_lib_bat\setcc.bat %CcName% x64
  call ..\bld_lib_bat\bld1_jpeg.bat x64 %Arg%
)
cd ..
goto :END


:gen_header
if not exist %4 mkdir %4
call :gen_header_print %1 %2 %3 >%4\%1
exit /b
:gen_header_print
echo /// %1 (official version) wrapper
echo #pragma once
echo #include "%2/%1"
echo #ifdef _MSC_VER
echo  #pragma comment(lib, "%3")
echo #endif
exit /b


:END
cd bld_lib_bat
endlocal
