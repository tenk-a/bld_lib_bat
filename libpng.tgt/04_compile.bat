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

  if /I "%ARG:~0,9%"=="ZlibIncDir:" set ZlibIncDir=%ARG:~10%
  if /I "%ARG:~0,9%"=="ZlibLibDir:" set ZlibLibDir=%ARG:~10%
  if /I "%ARG:~0,9%"=="ZlibFile:"   set ZlibFile=%ARG:~9%
  shift
goto ARG_LOOP
:ARG_LOOP_EXIT

if "%StrPrefix%"=="" (
  if not "%VcVer%"=="" (
    if "%StrPrefix%"=="" set StrPrefix=%VcVer%_
  )
)

rem if "%ZlibIncDir%"=="" ( for /D %%i in (..\zlib*.*) do set ZlibIncDir=%%i )
if "%ZlibLibDir%"=="" (
  set ZlibLibDir=%ZlibIncDir%\lib
)
if "%ZlibFile%"=="" (
  set ZlibFile=zlib.lib
)

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

if "%HasRtSta%%HasRel%"=="Sr" call :Bld1 rtsta rel %StrPrefix%%Arch%%StrRtSta%%StrRel%
if "%HasRtSta%%HasDbg%"=="Sd" call :Bld1 rtsta dbg %StrPrefix%%Arch%%StrRtSta%%StrDbg%
if "%HasRtDll%%HasRel%"=="Lr" call :Bld1 rtdll rel %StrPrefix%%Arch%%StrRtDll%%StrRel%
if "%HasRtDll%%HasDbg%"=="Ld" call :Bld1 rtdll dbg %StrPrefix%%Arch%%StrRtDll%%StrDbg%

endlocal
goto :EOF


:Bld1
set RtType=%1
set BldType=%2
set Target=%3

if exist *.obj del *.obj
if exist *.res del *.res
if exist *.manifest del *.manifest
if exist *.exp del *.exp
if exist *.exe del *.exe
if exist *.pdb del *.pdb

if "%RtType%"=="rtdll" (
  set RtOpts=-MD
) else (
  set RtOpts=-MT
)
if "%BldType%"=="dbg" (
  set BldOpts=-O2 -Zi
  set RtOpts=%RtOpts%d
) else (
  set BldOpts=-O2 -DNDEBUG
)

rem set CPPFLAGS=-I%ZlibIncDir%
set CFLAGS=-nologo -I%ZlibIncDir% -D_CRT_SECURE_NO_DEPRECATE -D_CRT_SECURE_NO_WARNINGS -W3 %RtOpts% %BldOpts%

nmake -f scripts/makefile.vcwin32 "CFLAGS=%CFLAGS%" "CPPFLAGS=%CPPFLAGS%"
if errorlevel 1 exit /b

if not "%HasTest%"=="1" goto TEST_SKIP
set TgtFile=%ZlibLibDir%\%Target%\%ZlibFile%
if exist %TgtFile% (
  cl %CPPFLAGS% %CFLAGS% pngtest.c libpng.lib %TgtFile%
  .\pngtest.exe
  if errorlevel 1 (
    echo ERROR: pngtest
    rem goto :EOF
  ) else (
    echo pngtest ok
  )
  if not exist exe mkdir exe
  if not exist exe\%Target% mkdir exe\%Target%
  if exist *.exe move *.exe exe\%Target%
)
:TEST_SKIP

set DstDir=%LibDir%\%Target%
if not exist %DstDir% mkdir %DstDir%
if exist *.lib move *.lib %DstDir%\

if exist *.obj del *.obj
if exist *.res del *.res
if exist *.manifest del *.manifest
if exist *.exp del *.exp
if exist *.exe del *.exe
if exist *.pdb del *.pdb

echo "%LibCopyDir%"

exit /b
