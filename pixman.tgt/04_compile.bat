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

if "%CcWinGnuMake%"=="" set CcWinGnuMake=mingw32-make.exe

if not exist Makefile.win32mt.common %TinyReplStr% ++ -MDd -$(RTOPT)d  -MD "-$(RTOPT) -DNDEBUG" -- Makefile.win32.common >Makefile.win32mt.common
if not exist Makefile.win32mt        %TinyReplStr% ++ Makefile.win32.common Makefile.win32mt.common "pixman -f Makefile.win32" "pixman -f Makefile.win32mt all" "all clean" "clean" -- Makefile.win32 >Makefile.win32mt

if not exist pixman\Makefile.win32mt %TinyReplStr% ++ Makefile.win32.common Makefile.win32mt.common -- pixman\Makefile.win32 >pixman\Makefile.win32mt

call :GetPixmanVersion
%TinyReplStr% ++ @PIXMAN_VERSION_MAJOR@ %PIXMAN_VERSION_MAJOR% @PIXMAN_VERSION_MINOR@ %PIXMAN_VERSION_MINOR% @PIXMAN_VERSION_MICRO@ %PIXMAN_VERSION_MICRO% -- pixman\pixman-version.h.in >pixman\pixman-version.h

if "%HasRtSta%%HasRel%"=="Sr" call :Bld1 static release
if "%HasRtSta%%HasDbg%"=="Sd" call :Bld1 static debug
if "%HasRtDll%%HasRel%"=="Lr" call :Bld1 rtdll  release
if "%HasRtDll%%HasDbg%"=="Ld" call :Bld1 rtdll  debug

goto END


:Bld1
set Rt=%1
set Conf=%2

set StrLibPath=
call %CcBatDir%\sub\StrLibPath.bat %CcTgtLibPathType% %CcTgtLibDir% %VcVer% %Arch% %Rt% %Conf%
set TgtLibDir=%StrLibPath%
if not exist %TgtLibDir% mkdir %TgtLibDir%

set RTOPT=
if "%Rt%"=="rtdll" (
  set RTOPT=MD
) else (
  set RTOPT=MT
)

set OPTS=SSE2=on SSSE3=off MMX=on
if "%Arch%"=="x64" (
  set OPTS=SSE2=on SSSE3=off MMX=off
)

rem if not exist pixman\pixman-version.h copy ..\bld_lib_bat\sub\pixman\pixman\pixman-version.h pixman\

if exist pixman\%Conf% if exist pixman\%Conf%\*.* del /q pixman\%Conf%\*.*

"%CcWinGnuMake%" -f Makefile.win32mt pixman %OPTS% "CFG=%Conf%" "RTOPT=%RTOPT%"

if not exist %TgtLibDir% mkdir %TgtLibDir%
if exist pixman\%Conf%\*.lib   move pixman\%Conf%\*.lib %TgtLibDir%\

exit /b


:GetPixmanVersion
if not exist %CcBatDir%\pixman.tgt\get_pixman_version.exe call :gen_get_pixman_version_exe
%CcBatDir%\pixman.tgt\get_pixman_version.exe configure.ac >__pixman_version.bat
call __pixman_version.bat
del  __pixman_version.bat
exit /b

:gen_get_pixman_version_exe
pushd %CcBatDir%\pixman.tgt
cl get_pixman_version.c
del get_pixman_version.obj
popd
exit /b

:END
endlocal
