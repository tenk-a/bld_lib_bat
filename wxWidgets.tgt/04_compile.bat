@echo off
rem This batch-file license: boost software license version 1.0
setlocal

set VcVer=%1
shift
set Arch=%1
shift

set HasRel=
set HasDbg=
set HasRtSta=
set HasRtDll=
set HasTest=
set LibDir=
set StrPrefix=
set StrRel=_release
set StrDbg=_debug
set StrRtSta=_static
set StrRtDll=

:ARG_LOOP
  set ARG=%1

  if "%ARG%"=="" goto ARG_LOOP_EXIT
  if /I "%ARG%"=="static"   set HasRtSta=S
  if /I "%ARG%"=="rtdll"    set HasRtDll=L
  if /I "%ARG%"=="release"  set HasRel=r
  if /I "%ARG%"=="debug"    set HasDbg=d
  if /I "%ARG%"=="test"     set HasTest=1

  if /I "%ARG:~0,7%"=="LibDir:"     set LibDir=%ARG:~7%
  if /I "%ARG:~0,10%"=="LibPrefix:" set StrPrefix=%ARG:~10%
  if /I "%ARG:~0,9%"=="LibRtSta:"   set StrRtSta=%ARG:~9%
  if /I "%ARG:~0,9%"=="LibRtDll:"   set StrRtDll=%ARG:~9%
  if /I "%ARG:~0,7%"=="LibRel:"     set StrRel=%ARG:~7%
  if /I "%ARG:~0,7%"=="LibDbg:"     set StrDbg=%ARG:~7%

  shift
goto ARG_LOOP
:ARG_LOOP_EXIT

if "%StrPrefix%"=="" (
  if not "%VcVer%"=="" (
    if "%StrPrefix%"=="" set StrPrefix=%VcVer%_
  )
)

if "%HasRtSta%%HasRtDll%"=="" (
  set HasRtSta=S
  set HasRtDll=L
)
if "%HasRel%%HasDbg%"=="" (
  set HasRel=r
  set HasDbg=d
)










rem Compile wxWidgets for vc
rem This batch-file license: boost software license version 1.0
setlocal

set VcVer=%1
shift
set Arch=%1
shift

set StrPrefix=

set StrRtSta=_static
set StrRtDll=
set StrDll=_dll

set HasRel=
set HasDbg=
set HasRtSta=
set HasRtDll=
set HasDll=
set HasTest=

set CppOpt="USE_OPENGL=1"

:ARG_LOOP
  set ARG=%1
  if "%ARG%"=="" goto ARG_LOOP_EXIT

  if /I "%ARG%"=="release" set HasRel=r
  if /I "%ARG%"=="debug"  set HasDbg=d
  if /I "%ARG%"=="static" set HasRtSta=S
  if /I "%ARG%"=="rtdll"  set HasRtDll=L
  if /I "%ARG%"=="dll"    set HasDll=D

  if /I "%ARG%"=="test"	  set HasTest=1

  if /I "%ARG:~0,7%"=="LibDir:"     set LibDir=%ARG:~7%
  if /I "%ARG:~0,10%"=="LibPrefix:" set StrPrefix=%ARG:~10%
  if /I "%ARG:~0,9%"=="LibRtSta:"   set StrRtSta=%ARG:~9%
  if /I "%ARG:~0,9%"=="LibRtDll:"   set StrRtDll=%ARG:~9%
  if /I "%ARG:~0,9%"=="LibDll:"     set StrDll=%ARG:~9%

  shift
goto ARG_LOOP
:ARG_LOOP_EXIT

if "%StrPrefix%"=="" (
  if not "%VcVer%"=="" (
    if "%StrPrefix%"=="" set StrPrefix=%VcVer%_
  )
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

rem if "%HasTest%"=="1"  call :BuildSample

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
