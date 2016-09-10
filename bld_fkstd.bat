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

if not "%1"=="" set "CcLibFksDir=%1"

if "%CcLibFksDir%"=="" (
  for /f %%i in ('dir /b /on /ad fks*') do set CcLibFksDir=%%i
)

if "%CcLibFksDir%"=="" (
  echo ERROR: not found source directory
  goto END
)


set Arg=libcopy:%CD%\%CcMiscLibDir% LibPrefix:%CcLibPrefix% release debug
if "%CcNoRtStatic%"=="1" (
  set Arg=%Arg% rtdll
) else (
  set Arg=%Arg% static rtdll
)

cd %CcLibFksDir%
call ..\bld_lib_bat\setcc.bat %Compl% %CcLibArchX86%
call ..\bld_lib_bat\bld1_fkstd.bat %CcLibArchX86% %Arg%
if "%CcHasX64%"=="1" (
  call ..\bld_lib_bat\setcc.bat %Compl% x64
  call ..\bld_lib_bat\bld1_fkstd.bat x64 %Arg%
)
cd ..

cd bld_lib_bat
endlocal
