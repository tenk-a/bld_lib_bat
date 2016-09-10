@echo off
rem This batch-file license: boost software license version 1.0
setlocal
call libs_config.bat
cd ..

if not exist %CcMiscIncDir% mkdir %CcMiscIncDir%
if not exist %CcMiscLibDir% mkdir %CcMiscLibDir%

set Compl=
if /I "%1"=="vc140" set Compl=vc140
if /I "%1"=="vc120" set Compl=vc120
if /I "%1"=="vc110" set Compl=vc110
if /I "%1"=="vc100" set Compl=vc100
if /I "%1"=="vc90"  set Compl=vc90
if /I "%1"=="vc80"  set Compl=vc80
if not "%Compl%"=="" (
  set CcLibPrefix=%Compl%_
  shift
) else (
  set Compl=%CcName%
)

if not "%1"=="" set "CcBzip2Dir=%1"

if "%CcBzip2Dir%"=="" (
  for /f %%i in ('dir /b /on /ad bzip2*') do set CcBzip2Dir=%%i
)

if "%CcBzip2Dir%"=="" (
  echo ERROR: not found source directory
  goto END
)

rem call :gen_header bzlib.h ../../%CcBzip2Dir% libbz2.lib %CcMiscIncDir%
call :gen_header bzlib.h ../%CcBzip2Dir% libbz2.lib %CcMiscIncDir%

set Arg=
set Arg=%Arg% libcopy:%CD%\%CcMiscLibDir%
set Arg=%Arg% LibDir:lib
set Arg=%Arg% LibPrefix:%CcLibPrefix%
set Arg=%Arg% LibRtSta:%CcLibStrStatic%
set Arg=%Arg% LibRtDll:%CcLibStrRtDll%
set Arg=%Arg% LibRel:%CcLibStrRelease%
set Arg=%Arg% LibDbg:%CcLibStrDebug%

if "%CcNoRtStatic%"=="1" set Arg=%Arg% rtdll

cd %CcBzip2Dir%
call ..\bld_lib_bat\setcc.bat %Compl% %CcLibArchX86%
call ..\bld_lib_bat\bld1_bzip2.bat %CcLibArchX86% %Arg%
if "%CcHasX64%"=="1" (
  call ..\bld_lib_bat\setcc.bat %Compl% x64
  call ..\bld_lib_bat\bld1_bzip2.bat x64 %Arg%
)
cd ..
goto END

:gen_header
if not exist %4 mkdir %4
call :gen_header_print %1 %2 %3 >%4\%1
exit /b
:gen_header_print
echo /// %1 wrapper
echo #pragma once
echo #include "%2/%1"
echo #ifdef _MSC_VER
echo  #pragma comment(lib, "%3")
echo #endif
exit /b

:END
cd bld_lib_bat
endlocal
