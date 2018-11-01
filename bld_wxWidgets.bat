@echo off
rem This batch-file license: boost software license version 1.0
setlocal
call libs_config.bat

set TgtName=wxWidgets
set TgtDir=
set SrcLibSubDir=%CcLibDir%
set Arg=%CcBld1Arg%

pushd ..

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

if "%TgtDir%"=="" (
  for /f %%i in ('dir /b /on /ad %TgtName%*') do set TgtDir=%%i
)

if "%TgtDir%"=="" (
  echo ERROR: not found source directory
  goto END
)
if not exist "%TgtDir%" (
  echo ERROR: not found source directory
  goto END
)

set Arg=%Arg% LibPrefix:%LibPrefix% LibDir:%SrcLibSubDir%
set Arg=%Arg% LibRtSta:%CcLibStrStatic% LibRtDll:%CcLibStrRtDll% LibDll:%CcLibStrDll%
if "%CcNoRtStatic%"=="1" set Arg=%Arg% rtdll

rem goto BUILD_SKIP
pushd %TgtDir%
if "%CcHasX86%"=="1" (
  call ..\bld_lib_bat\setcc.bat %VcVer% Win32
  call ..\bld_lib_bat\bld1_%TgtName%.bat %VcVer% Win32 %Arg%
)
if "%CcHasX64%"=="1" (
  call ..\bld_lib_bat\setcc.bat %VcVer% x64
  call ..\bld_lib_bat\bld1_%TgtName%.bat %VcVer% x64 %Arg%
)
popd
:BUILD_SKIP


:END
popd
endlocal
