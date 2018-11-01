@echo off
rem This batch-file license: boost software license version 1.0
setlocal
call libs_config.bat

set TgtName=boost
set Arg=%CcBld1Arg%

set VcVer=
:ARG_LOOP
  if "%1"=="" goto ARG_LOOP_EXIT

  if not "%VcVer%"=="" goto VCVAR_SKIP
  if /I "%1"=="vc71"     set VcVer=vc71
  if /I "%1"=="vc80"     set VcVer=vc80
  if /I "%1"=="vc90"     set VcVer=vc90
  if /I "%1"=="vc100"    set VcVer=vc100
  if /I "%1"=="vc110"    set VcVer=vc110
  if /I "%1"=="vc120"    set VcVer=vc120
  if /I "%1"=="vc130"    set VcVer=vc130
  if /I "%1"=="vc140"    set VcVer=vc140
  if /I "%1"=="vc141"    set VcVer=vc141
  goto ARG_NEXT
:VCVAR_SKIP
  if "%TgtDir%"==""      set TgtDir=%1
:ARG_NEXT
  shift
goto ARG_LOOP
:ARG_LOOP_EXIT

set LibPrefix=%VcVer%_
if "%VcVer%"=="" (
  set VcVer=%CcName%
  set LibPrefix=%CcLibPrefix%
)

pushd ..

if "%TgtDir%"=="" (
  for /f %%i in ('dir /b /on /ad %TgtName%*') do set TgtDir=%%i
)

if "%TgtDir%"=="" (
  echo ERROR: not found source directory
  goto END
)

if "%CcZlibDir%"=="" (
  for /f %%i in ('dir /b /on /ad zlib*') do set CcZlibDir=%CD%\%%i
)
if "%CcBzip2Dir%"=="" (
  for /f %%i in ('dir /b /on /ad bzip2*') do set CcBzip2Dir=%CD%\%%i
)

cd %TgtDir%
set Arg=%Arg% zlib:%CcZlibDir% bzip2:%CcBzip2Dir% LibPrefix:%LibPrefix%
if "%CcHasX86%"=="1" (
  call ..\bld_lib_bat\setcc.bat          %VcVer% Win32
  call ..\bld_lib_bat\bld1_%TgtName%.bat %VcVer% Win32 %Arg%
)
if "%CcHasX64%"=="1" (
  call ..\bld_lib_bat\setcc.bat          %VcVer% x64
  call ..\bld_lib_bat\bld1_%TgtName%.bat %VcVer% x64 %Arg%
)
cd ..

:END
popd
endlocal
