@echo off
rem This batch-file license: boost software license version 1.0
setlocal
call libs_config.bat
cd ..

if not exist %CcMiscIncDir% mkdir %CcMiscIncDir%
if not exist %CcMiscLibDir% mkdir %CcMiscLibDir%

if not "%1"=="" set "CcZlibDir=%1"

if "%CcZlibDir%"=="" (
  for /f %%i in ('dir /b /on /ad zlib*') do set CcZlibDir=%%i
)

if "%CcZlibDir%"=="" (
  echo ERROR: not found source directory
  goto END
)

rem call :gen_header zlib.h  ../../%CcZlibDir% %CcMiscIncDir%\zlib
rem call :gen_header zconf.h ../../%CcZlibDir% %CcMiscIncDir%\zlib
call :gen_header zlib.h  ../%CcZlibDir% %CcMiscIncDir%
call :gen_header zconf.h ../%CcZlibDir% %CcMiscIncDir%

set Arg=libcopy:%CD%\%CcMiscLibDir%
if "%CcNoRtStatic%"=="1" set Arg=%Arg% rtdll

cd %CcZlibDir%
call ..\bld_lib_bat\setcc.bat %CcName% x86
call ..\bld_lib_bat\bld1_zlib.bat x86 %Arg%
if "%CcHasX64%"=="1" (
  call ..\bld_lib_bat\setcc.bat %CcName% x64
  call ..\bld_lib_bat\bld1_zlib.bat x64 %Arg%
)
cd ..
goto END

:gen_header
if not exist %3 mkdir %3
call :gen_header_print %1 %2 >%3\%1
exit /b
:gen_header_print
echo /// %1 wrapper
echo #pragma once
echo #include "%2/%1"
echo #ifdef _MSC_VER
echo  #ifdef ZLIB_DLL
echo   #pragma comment(lib, "zdll.lib")
echo  #else
echo   #pragma comment(lib, "zlib.lib")
echo  #endif
echo #endif
exit /b

:END
cd bld_lib_bat
endlocal
