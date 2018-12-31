rem @echo off
rem Compile cairo for vc
rem This batch-file license: boost software license version 1.0
setlocal

set Arch=
set LibDir=
set StrPrefix=
set StrRel=_release
set StrDbg=_debug
set StrRtSta=_static
set StrRtDll=
set StrDll=_dll

set HasRel=
set HasDbg=
set HasRtSta=
set HasRtDll=
set VcVer=

:ARG_LOOP
  if "%1"=="" goto ARG_LOOP_EXIT

  if /I "%1"=="x86"      set Arch=Win32
  if /I "%1"=="Win32"    set Arch=Win32
  if /I "%1"=="x64"      set Arch=x64

  if /I "%1"=="static"   set HasRtSta=S
  if /I "%1"=="rtsta"    set HasRtSta=S
  if /I "%1"=="rtdll"    set HasRtDll=L

  if /I "%1"=="release"  set HasRel=r
  if /I "%1"=="debug"    set HasDbg=d

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
  if /I "%ARG:~0,7%"=="LibRel:"     set StrRel=%ARG:~7%
  if /I "%ARG:~0,7%"=="LibDbg:"     set StrDbg=%ARG:~7%

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
  if "%VcVer%"=="vc141"    if /I not "%PATH:\bin\HostX64\x64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 14.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 13.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 12.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 11.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 10.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 9.0\VC\BIN\amd64=%"=="%PATH%"  set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 8\VC\BIN\amd64=%"=="%PATH%"    set Arch=x64
)
if "%Arch%"=="" set Arch=Win32

if "%HasRtSta%%HasRtDll%"=="" (
  set HasRtSta=S
  set HasRtDll=L
)
if "%HasRel%%HasDbg%"=="" (
  set HasRel=r
  set HasDbg=d
)

set ADD_COPTS=
if "%VcVer%"=="vc140" set ADD_COPTS=-utf-8
if "%VcVer%"=="vc141" set ADD_COPTS=-utf-8

if "%LibDir%"=="" set LibDir=lib
if not exist %LibDir% mkdir %LibDir%

if not exist build\Makefile.win32.common.orig	copy build\Makefile.win32.common build\Makefile.win32.common.orig

..\bld_lib_bat\tiny_replstr.exe ++ "CFG_CFLAGS := -MDd -Od -Zi" "CFG_CFLAGS := -$(RTOPT)d -Od -Zi %ADD_COPTS%" "CFG_CFLAGS := -MD -O2" "CFG_CFLAGS := -$(RTOPT) -DNDEBUG -O2 %ADD_COPTS%" "PIXMAN_LIBS := $(PIXMAN_PATH)/pixman/$(CFG)/pixman-1.lib" "PIXMAN_LIBS := $(PIXMAN_LIB_PATH)/pixman-1.lib" "CAIRO_LIBS +=  $(LIBPNG_PATH)/libpng.lib" "CAIRO_LIBS +=  $(LIBPNG_LIB_PATH)/libpng.lib" "CAIRO_LIBS += $(ZLIB_PATH)/zdll.lib" "CAIRO_LIBS += $(ZLIB_LIB_PATH)/zdll.lib" -- build\Makefile.win32.common.orig >build\Makefile.win32.common

set "SV_PATH=%PATH%"
set "PATH=%CcMsys1Paths%;%PATH%"


if "%HasRtSta%%HasRel%"=="Sr" call :Bld1 rtsta rel %StrPrefix%%Arch%%StrRtSta%%StrRel%
if "%HasRtSta%%HasDbg%"=="Sd" call :Bld1 rtsta dbg %StrPrefix%%Arch%%StrRtSta%%StrDbg%
if "%HasRtDll%%HasRel%"=="Lr" call :Bld1 rtdll rel %StrPrefix%%Arch%%StrRtDll%%StrRel%
if "%HasRtDll%%HasDbg%"=="Ld" call :Bld1 rtdll dbg %StrPrefix%%Arch%%StrRtDll%%StrDbg%

set "PATH=%SV_PATH%"

move build\Makefile.win32.common build\Makefile.win32.common.tmp
move build\Makefile.win32.orig   build\Makefile.win32.common

goto END


:Bld1
set RtType=%1
set BldType=%2
set Target=%3

set RTOPT=
if "%RtType%"=="rtdll" (
  set RTOPT=MD
) else (
  set RTOPT=MT
)

set CFG=release
if "%BldType%"=="dbg" (
  set CFG=debug
)

if exist src\debug\*.* del /s /q src\debug\*.*
if exist src\release\*.* del /s /q src\release\*.*

pushd src
set MINC=../../%CcLibsVcIncDir%
set MLIB=../../%CcLibsVcLibDir%/%Target%
make -f Makefile.win32 "CFG=%CFG%" "RTOPT=%RTOPT%" "PIXMAN_PATH=%MINC%" "LIBPNG_PATH=%MINC%" "ZLIB_PATH=%MINC%" "PIXMAN_LIB_PATH=%MLIB%" "LIBPNG_LIB_PATH=%MLIB%" "ZLIB_LIB_PATH=%MLIB%"
popd

if not exist %LibDir%\%Target% mkdir %LibDir%\%Target%
if exist src\%CFG%\*.lib     copy src\%CFG%\*.lib %LibDir%\%Target%\
if exist src\%CFG%\*.dll     copy src\%CFG%\*.dll %LibDir%\%Target%\
if exist src\%CFG%\cairo.pdb copy src\%CFG%\cairo.pdb %LibDir%\%Target%\

exit /b


:END
endlocal
