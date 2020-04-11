rem @echo off
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

:ARG_LOOP
  set ARG=%1

  if "%ARG%"=="" goto ARG_LOOP_EXIT
  if /I "%ARG%"=="static"   set HasRtSta=S
  if /I "%ARG%"=="rtdll"    set HasRtDll=L
  if /I "%ARG%"=="release"  set HasRel=r
  if /I "%ARG%"=="debug"    set HasDbg=d
  if /I "%ARG%"=="test"     set HasTest=1

  shift
goto ARG_LOOP
:ARG_LOOP_EXIT

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
if "%VcVer%"=="vc142" set ADD_COPTS=-utf-8

if not exist build\Makefile.win32.common.orig	copy build\Makefile.win32.common build\Makefile.win32.common.orig

"%TinyReplStr%" ++ "CFG_CFLAGS := -MDd -Od -Zi" "CFG_CFLAGS := -$(RTOPT)d -Od -Zi %ADD_COPTS%" "CFG_CFLAGS := -MD -O2" "CFG_CFLAGS := -$(RTOPT) -DNDEBUG -O2 %ADD_COPTS%" "PIXMAN_LIBS := $(PIXMAN_PATH)/pixman/$(CFG)/pixman-1.lib" "PIXMAN_LIBS := $(PIXMAN_LIB_PATH)/pixman-1.lib" "CAIRO_LIBS +=  $(LIBPNG_PATH)/libpng.lib" "CAIRO_LIBS +=  $(LIBPNG_LIB_PATH)/libpng.lib" "CAIRO_LIBS += $(ZLIB_PATH)/zdll.lib" "CAIRO_LIBS += $(ZLIB_LIB_PATH)/zdll.lib" -- build\Makefile.win32.common.orig >build\Makefile.win32.common

set "SV_PATH=%PATH%"
set "PATH=%CcMsys1Paths%;%PATH%"


if "%HasRtSta%%HasRel%"=="Sr" call :Bld1 static release
if "%HasRtSta%%HasDbg%"=="Sd" call :Bld1 static debug
if "%HasRtDll%%HasRel%"=="Lr" call :Bld1 rtdll release
if "%HasRtDll%%HasDbg%"=="Ld" call :Bld1 rtdll debug

set "PATH=%SV_PATH%"

move build\Makefile.win32.common build\Makefile.win32.common.tmp
move build\Makefile.win32.orig   build\Makefile.win32.common

goto END


:Bld1
set Rt=%1
set Conf=%2

set RTOPT=
if "%Rt%"=="rtdll" (
  set RTOPT=MD
) else (
  set RTOPT=MT
)

if exist src\debug\*.* del /s /q src\debug\*.*
if exist src\release\*.* del /s /q src\release\*.*

set StrLibPath=
call %CcBatDir%\sub\StrLibPath.bat %CcInstallPathType% %CcInstallLibDir% %VcVer% %Arch% %Rt% %Conf%
set DstLibDir=%StrLibPath%
if "%DstLibDir%"=="" (
  echo [ERROR] No %%CcInstallPathType%% [CcInstallPathType=%CcInstallPathType% VcVer=%VcVer% Arch=%Arch% Rt=%Rt% Conf=%Conf%]
  pause
)

pushd src
rem set MINC=%CcInstallIncDir%
set MINC=../../include
set MLIB=%DstLibDir%
make -f Makefile.win32 "CFG=%Conf%" "RTOPT=%RTOPT%" "PIXMAN_PATH=%MINC%" "LIBPNG_PATH=%MINC%" "ZLIB_PATH=%MINC%" "PIXMAN_LIB_PATH=%MLIB%" "LIBPNG_LIB_PATH=%MLIB%" "ZLIB_LIB_PATH=%MLIB%"
popd

set StrLibPath=
call %CcBatDir%\sub\StrLibPath.bat %CcTgtLibPathType% %CcTgtLibDir% %VcVer% %Arch% %Rt% %Conf%
set TgtLibDir=%StrLibPath%
if not exist %TgtLibDir% mkdir %TgtLibDir%

if not exist %TgtLibDir% mkdir %TgtLibDir%
if exist src\%Conf%\*.lib     copy src\%Conf%\*.lib %TgtLibDir%\
if exist src\%Conf%\*.dll     copy src\%Conf%\*.dll %TgtLibDir%\
if exist src\%Conf%\cairo.pdb copy src\%Conf%\cairo.pdb %TgtLibDir%\

exit /b


:END
endlocal
