rem @echo off
rem Compile wxWidgets for vc
rem bld1_wxWidgets [win32/x64] [static/rtdll/dll] [libdir:DEST_DIR]
rem ex)
rem cd wxWidgets-3.0.2
rem ..\bld_lib_bat\bld1_wxWidgets.bat x64
rem
rem This batch-file license: boost software license version 1.0
setlocal

set Arch=
set StrPrefix=

set StrRtSta=_static
set StrRtDll=
set StrDll=_dll

set HasRtSta=
set HasRtDll=
set HasDll=
set VcVer=

set CppOpt="USE_OPENGL=1"

:ARG_LOOP
  if "%1"=="" goto ARG_LOOP_EXIT

  if /I "%1"=="x86"      set Arch=Win32
  if /I "%1"=="win32"    set Arch=Win32
  if /I "%1"=="x64"      set Arch=x64

  if /I "%1"=="static"   set HasRtSta=S
  if /I "%1"=="rtsta"    set HasRtSta=S
  if /I "%1"=="rtdll"    set HasRtDll=L
  if /I "%1"=="dll"      set HasDll=D

  if /I "%1"=="vc71"     set VcVer=vc71
  if /I "%1"=="vc80"     set VcVer=vc80
  if /I "%1"=="vc90"     set VcVer=vc90
  if /I "%1"=="vc100"    set VcVer=vc100
  if /I "%1"=="vc110"    set VcVer=vc110
  if /I "%1"=="vc120"    set VcVer=vc120
  if /I "%1"=="vc130"    set VcVer=vc130
  if /I "%1"=="vc140"    set VcVer=vc140
  if /I "%1"=="vc141"    set VcVer=vc141

  set ARG=%1
  if /I "%ARG:~0,7%"=="LibDir:"     set LibDir=%ARG:~7%
  if /I "%ARG:~0,10%"=="LibPrefix:" set StrPrefix=%ARG:~10%
  if /I "%ARG:~0,9%"=="LibRtSta:"   set StrRtSta=%ARG:~9%
  if /I "%ARG:~0,9%"=="LibRtDll:"   set StrRtDll=%ARG:~9%
  if /I "%ARG:~0,9%"=="LibDll:"     set StrDll=%ARG:~9%

  shift
goto ARG_LOOP
:ARG_LOOP_EXIT

if "%VcVer%"=="" (
  if /I not "%PATH:Microsoft Visual Studio .NET 2003=%"=="%PATH%" set VcVer=vc71
  if /I not "%PATH:Microsoft Visual Studio 8=%"=="%PATH%"    set VcVer=vc80
  if /I not "%PATH:Microsoft Visual Studio 9.0=%"=="%PATH%"  set VcVer=vc90
  if /I not "%PATH:Microsoft Visual Studio 10.0=%"=="%PATH%" set VcVer=vc100
  if /I not "%PATH:Microsoft Visual Studio 11.0=%"=="%PATH%" set VcVer=vc110
  if /I not "%PATH:Microsoft Visual Studio 12.0=%"=="%PATH%" set VcVer=vc120
  if /I not "%PATH:Microsoft Visual Studio 13.0=%"=="%PATH%" set VcVer=vc130
  if /I not "%PATH:Microsoft Visual Studio 14.0=%"=="%PATH%" set VcVer=vc140
  if /I not "%PATH:Microsoft Visual Studio\2017=%"=="%PATH%" set VcVer=vc141
)

if "%StrPrefix%"=="" (
  if not "%VcVer%"=="" (
    if "%StrPrefix%"=="" set StrPrefix=%VcVer%_
  )
)

if "%Arch%"=="" (
  if /I not "%PATH:Microsoft Visual Studio 14.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 13.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 12.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 11.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 10.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 9.0\VC\BIN\amd64=%"=="%PATH%"  set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 8\VC\BIN\amd64=%"=="%PATH%"    set Arch=x64
)
if "%Arch%"=="" set Arch=Win32
set ArchName=%Arch%_
if "%Arch%"=="Win32" set ArchName=


if "%HasRtSta%%HasRtDll%%HasDll%"=="" (
  set HasRtSta=S
  set HasRtDll=L
  set HasDll=D
)

if "%HasRtSta%"=="S" call :Bld1 "RUNTIME_LIBS=static"  static_lib lib
if "%HasRtDll%"=="L" call :Bld1 "RUNTIME_LIBS=dynamic" rtdll_lib  lib
if "%HasDll%"=="D"   call :Bld1 "SHARED=1"             dll        dll

endlocal
goto :EOF

:Bld1
set RtOpt=%~1
set Postfix=%2
set TargetOldPostfix=%3

set TargetOld=vc_
if "%Arch%"=="x64" set TargetOld=%TargetOld%%Arch%_
set TargetOld=%TargetOld%%TargetOldPostfix%

set Target=%StrPrefix%%ArchName%%Postfix%

set CpuOpt=
if "%Arch%"=="x64" set "CpuOpt=TARGET_CPU=X64"

set CFLAGSSET=
rem if /I "%CcName%"=="vc140" set "CFLAGSSET=CFLAGS=-Dsnprintf=snprintf"

cd .\build\msw
nmake -f makefile.vc %CpuOpt% %RtOpt% %CppOpt% %CFLAGSSET% BUILD=release clean
nmake -f makefile.vc %CpuOpt% %RtOpt% %CppOpt% %CFLAGSSET% BUILD=release
rem nmake -f makefile.vc %CpuOpt% %RtOpt% %CppOpt% %CFLAGSSET% BUILD=debug   clean
rem nmake -f makefile.vc %CpuOpt% %RtOpt% %CppOpt% %CFLAGSSET% BUILD=debug
cd ..\..

if not %TargetOld%==%Target% (
  move lib\%TargetOld% lib\%Target%
)

exit /b
