rem @echo off
rem Compile pixman for vc
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

if "%LibDir%"=="" set LibDir=lib
if not exist %LibDir% mkdir %LibDir%

if "%CcWinGnuMake%"=="" set CcWinGnuMake=mingw32-make.exe

if not exist Makefile.win32mt.common ..\bld_lib_bat\tiny_replstr.exe ++ -MDd -$(RTOPT)d  -MD "-$(RTOPT) -DNDEBUG" -- Makefile.win32.common >Makefile.win32mt.common
if not exist Makefile.win32mt        ..\bld_lib_bat\tiny_replstr.exe ++ Makefile.win32.common Makefile.win32mt.common "pixman -f Makefile.win32" "pixman -f Makefile.win32mt all" "all clean" "clean" -- Makefile.win32 >Makefile.win32mt

if not exist pixman\Makefile.win32mt ..\bld_lib_bat\tiny_replstr.exe ++ Makefile.win32.common Makefile.win32mt.common -- pixman\Makefile.win32 >pixman\Makefile.win32mt

call :GetPixmanVersion
..\bld_lib_bat\tiny_replstr.exe ++ @PIXMAN_VERSION_MAJOR@ %PIXMAN_VERSION_MAJOR% @PIXMAN_VERSION_MINOR@ %PIXMAN_VERSION_MINOR% @PIXMAN_VERSION_MICRO@ %PIXMAN_VERSION_MICRO% -- pixman\pixman-version.h.in >pixman\pixman-version.h

if "%HasRtSta%%HasRel%"=="Sr" call :Bld1 rtsta rel %StrPrefix%%Arch%%StrRtSta%%StrRel%
if "%HasRtSta%%HasDbg%"=="Sd" call :Bld1 rtsta dbg %StrPrefix%%Arch%%StrRtSta%%StrDbg%
if "%HasRtDll%%HasRel%"=="Lr" call :Bld1 rtdll rel %StrPrefix%%Arch%%StrRtDll%%StrRel%
if "%HasRtDll%%HasDbg%"=="Ld" call :Bld1 rtdll dbg %StrPrefix%%Arch%%StrRtDll%%StrDbg%

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
set OPTS=SSE2=on SSSE3=off MMX=on
if "%Arch%"=="x64" (
  set OPTS=SSE2=on SSSE3=off MMX=off
)

rem if not exist pixman\pixman-version.h copy ..\bld_lib_bat\sub\pixman\pixman\pixman-version.h pixman\

if exist pixman\%CFG% if exist pixman\%CFG%\*.* del /q pixman\%CFG%\*.*

%CcWinGnuMake% -f Makefile.win32mt pixman %OPTS% "CFG=%CFG%" "RTOPT=%RTOPT%"

if not exist %LibDir%\%Target% mkdir %LibDir%\%Target%
if exist pixman\%CFG%\*.lib    move pixman\%CFG%\*.lib %LibDir%\%Target%\

exit /b


:GetPixmanVersion
if not exist ..\bld_lib_bat\get_pixman_version.exe call :gen_get_pixman_version_exe
..\bld_lib_bat\get_pixman_version.exe configure.ac >__pixman_version.bat
call __pixman_version.bat
del  __pixman_version.bat
exit /b

:gen_get_pixman_version_exe
pushd ..\bld_lib_bat
cl src\get_pixman_version.c
del get_pixman_version.obj
popd
exit /b

:END
endlocal
