@rem This batch-file license: boost software license version 1.0
@echo off
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

  if /I "%ARG:~0,9%"=="ZlibIncDir:" set ZlibIncDir=%ARG:~10%
  if /I "%ARG:~0,9%"=="ZlibLibDir:" set ZlibLibDir=%ARG:~10%
  if /I "%ARG:~0,9%"=="ZlibFile:"   set ZlibFile=%ARG:~9%
  shift
goto ARG_LOOP
:ARG_LOOP_EXIT

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

if "%HasRtSta%%HasRel%"=="Sr" call :Bld1 static release
if "%HasRtSta%%HasDbg%"=="Sd" call :Bld1 static debug
if "%HasRtDll%%HasRel%"=="Lr" call :Bld1 rtdll  release
if "%HasRtDll%%HasDbg%"=="Ld" call :Bld1 rtdll  debug

goto END


:Bld1
set Rt=%1
set Conf=%2
set Target=%3

set StrLibPath=
call %CcBatDir%\sub\StrLibPath.bat %CcTgtLibPathType% %CcTgtLibDir% %VcVer% %Arch% %Rt% %Conf%
set TgtLibDir=%StrLibPath%
if not exist %TgtLibDir% mkdir %TgtLibDir%

if exist *.obj del *.obj
if exist *.res del *.res
if exist *.manifest del *.manifest
if exist *.exp del *.exp
if exist *.exe del *.exe
if exist *.pdb del *.pdb

if "%Rt%"=="rtdll" (
  set RtOpts=-MD
) else (
  set RtOpts=-MT
)
if "%Conf%"=="debug" (
  set BldOpts=-O2 -Zi
  set RtOpts=%RtOpts%d
) else (
  set BldOpts=-O2 -DNDEBUG
)

rem set CPPFLAGS=-I%ZlibIncDir%
set CFLAGS=-nologo -I%ZlibIncDir% -D_CRT_SECURE_NO_DEPRECATE -D_CRT_SECURE_NO_WARNINGS -W3 %RtOpts% %BldOpts%

nmake -f scripts/makefile.vcwin32 "CFLAGS=%CFLAGS%" "CPPFLAGS=%CPPFLAGS%"
if errorlevel 1 exit /b

if "%HasTest%"=="1" call :TEST

if not exist %TgtLibDir% mkdir %TgtLibDir%
if exist *.lib move *.lib %TgtLibDir%\

if exist *.obj del *.obj
if exist *.res del *.res
if exist *.manifest del *.manifest
if exist *.exp del *.exp
if exist *.exe del *.exe
if exist *.pdb del *.pdb

echo "%LibCopyDir%"

exit /b

:TEST
set StrLibPath=
call %CcBatDir%\sub\StrLibPath.bat %CcTgtLibPathType% exe %VcVer% %Arch% %Rt% %Conf%
set ExeDir=%StrLibPath%
set StrLibPath=
call %CcBatDir%\sub\StrLibPath.bat %CcTgtLibPathType% %ZlibLibDir% %VcVer% %Arch% %Rt% %Conf%
set ZipLibPath=%StrLibPath%\%ZlibFile%
if not exist %ZipLibPath% goto TEST_SKIP1
  cl %CPPFLAGS% %CFLAGS% pngtest.c libpng.lib %ZipLibPath%
  .\pngtest.exe
  if errorlevel 1 (
    echo ERROR: pngtest
    pause
  ) else (
    echo pngtest ok
  )
  if not exist %ExeDir% mkdir %ExeDir%
  if exist *.exe move *.exe %ExeDir%\
:TEST_SKIP1
exit /b

:END
endlocal
exit /b
