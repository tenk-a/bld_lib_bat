@echo off
rem This batch-file license: boost software license version 1.0
setlocal
call libs_config.bat
cd ..

if not exist %CcMiscIncDir% mkdir %CcMiscIncDir%
if not exist %CcMiscLibDir% mkdir %CcMiscLibDir%

if not "%1"=="" set "CcBzip2Dir=%1"

if "%CcBzip2Dir%"=="" (
  for /f %%i in ('dir /b /on /ad bzip2*') do set CcBzip2Dir=%%i
)

if "%CcBzip2Dir%"=="" (
  echo ERROR: not found source directory
  goto END
)

call bld_lib_bat\gen_header.bat bzlib.h %CcBzip2Dir% libbz2.lib %CcMiscIncDir%\bzip2

set Arg=libcopy:%CD%\%CcMiscLibDir%
if "%CcNoRtStatic%"=="1" set Arg=%Arg% rtdll

cd %CcBzip2Dir%
call ..\bld_lib_bat\setcc.bat %CcName% x86
call ..\bld_lib_bat\bld1_bzip2.bat x86 %Arg%
if "%CcHasX64%"=="1" (
  call ..\bld_lib_bat\setcc.bat %CcName% x64
  call ..\bld_lib_bat\bld1_bzip2.bat x64 %Arg%
)
cd ..

:END
cd bld_lib_bat
endlocal
