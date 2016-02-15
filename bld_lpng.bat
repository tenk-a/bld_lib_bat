@echo off
rem This batch-file license: boost software license version 1.0
setlocal
call libs_config.bat
cd ..

if not exist %CcMiscIncDir% mkdir %CcMiscIncDir%
if not exist %CcMiscLibDir% mkdir %CcMiscLibDir%

if not "%1"=="" set "CcLibPngDir=%1"

if "%CcLibPngDir%"=="" (
  for /f %%i in ('dir /b /on /ad lpng*') do set CcLibPngDir=%%i
)

if "%CcLibPngDir%"=="" (
  echo ERROR: not found source directory
  goto END
)

rem call :gen_header png.h ../../%CcLibPngDir% %CcMiscIncDir%\png
call :gen_header png.h ../%CcLibPngDir% %CcMiscIncDir%

set Arg=libcopy:%CD%\%CcMiscLibDir%
if "%CcNoRtStatic%"=="1" set Arg=%Arg% rtdll

cd %CcLibPngDir%
call ..\bld_lib_bat\setcc.bat %CcName% x86
call ..\bld_lib_bat\bld1_lpng.bat x86 %Arg%
if "%CcHasX64%"=="1" (
  call ..\bld_lib_bat\setcc.bat %CcName% x64
  call ..\bld_lib_bat\bld1_lpng.bat x64 %Arg%
)
cd ..

endlocal
goto :END

:gen_header
if not exist %3 mkdir %3
call :gen_header_print %1 %2 >%3\%1
exit /b
:gen_header_print
echo /// %1 (official version) wrapper
echo #pragma once
echo #include "%2/%1"
echo #ifdef _MSC_VER
echo  #pragma comment(lib, "libpng.lib")
echo  #pragma comment(lib, "zlib.lib")
echo #endif
exit /b

:END
cd bld_lib_bat
endlocal
