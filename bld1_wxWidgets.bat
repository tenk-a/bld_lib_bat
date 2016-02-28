rem @echo off
rem Compile wxWidgets for vc
rem bld1_wxWidgets [x86/x64] [static/rtdll/dll] [libdir:DEST_DIR]
rem ex)
rem cd wxWidgets-3.0.2
rem ..\bld_lib_bat\bld1_wxWidgets.bat x64
rem
rem This batch-file license: boost software license version 1.0
setlocal

set Arch=%CcArch%
set StrPrefix=%CcLibPrefix%
if "%StrPrefix%"=="" set StrPrefix=vc_

set HasRtSta=
set HasRtDll=
set HasDll=

set LibArchX86=%CcLibArchX86%
if "%LibArchX86%"=="" set LibArchX86=Win32

:ARG_LOOP
  if "%1"=="" goto ARG_LOOP_EXIT

  if /I "%1"=="x86"      set Arch=%LibArchX86%
  if /I "%1"=="win32"    set Arch=%LibArchX86%
  if /I "%1"=="x64"      set Arch=x64

  if /I "%1"=="static"   set HasRtSta=S
  if /I "%1"=="rtsta"    set HasRtSta=S
  if /I "%1"=="rtdll"    set HasRtDll=L
  if /I "%1"=="dll"      set HasDll=D

  set ARG=%1
  if /I "%ARG:~0,7%"=="LibDir:"     set LibDir=%ARG:~7%
  if /I "%ARG:~0,10%"=="LibPrefix:" set StrPrefix=%ARG:~10%

  shift
goto ARG_LOOP
:ARG_LOOP_EXIT

if "%Arch%"=="" (
  if /I not "%PATH:Microsoft Visual Studio 13.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 12.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 11.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 10.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 9.0\VC\BIN\amd64=%"=="%PATH%"  set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 8\VC\BIN\amd64=%"=="%PATH%"    set Arch=x64
)
if "%Arch%"=="" set Arch=%LibArchX86%

if "%HasRtSta%%HasRtDll%%HasDll%"=="" (
  set HasRtSta=S
  set HasRtDll=L
  set HasDll=D
)

if "%HasRtDll%"=="L" call :Bld1 "RUNTIME_LIBS=dynamic" lib_rtdll
if "%HasRtSta%"=="S" call :Bld1 "RUNTIME_LIBS=static"  lib
if "%HasDll%"=="D"   call :Bld1 "SHARED=1"             dll

endlocal
goto :EOF

:Bld1
set RtOpt=%~1
set Postfix=%2

set TargetOld=vc_
if not "%Arch%"=="x86" set TargetOld=%TargetOld%%Arch%_
if "%Postfix%"=="lib_rtdll" (
  set TargetOld=%TargetOld%lib
) else (
  set TargetOld=%TargetOld%%Postfix%
)

set Target=%StrPrefix%
if not "%Arch%"=="x86" set Target=%Target%%Arch%_
set Target=%Target%%Postfix%

set CpuOpt=
if %Arch%==x64 set "CpuOpt=TARGET_CPU=X64"

cd .\build\msw
nmake -f makefile.vc %CpuOpt% %RtOpt% BUILD=release clean
nmake -f makefile.vc %CpuOpt% %RtOpt% BUILD=release
nmake -f makefile.vc %CpuOpt% %RtOpt% BUILD=debug   clean
nmake -f makefile.vc %CpuOpt% %RtOpt% BUILD=debug
cd ..\..

if not %TargetOld%==%Target% (
  move lib\%TargetOld% lib\%Target%
)

exit /b
