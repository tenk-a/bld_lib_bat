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

if "%HasRtSta%%HasRel%"=="Sr" call :Bld1 static release
if errorlevel 1 goto ERR

if "%HasRtSta%%HasDbg%"=="Sd" call :Bld1 static debug
if errorlevel 1 goto ERR

if "%HasRtDll%%HasRel%"=="Lr" call :Bld1 rtdll  release
if errorlevel 1 goto ERR

if "%HasRtDll%%HasDbg%"=="Ld" call :Bld1 rtdll  debug
if errorlevel 1 goto ERR

goto END


:Bld1
set Rt=%1
set Conf=%2
set Target=%3

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

if not exist win32/Maikefile.vc call :MkMakefileVC
set CFLAGS=-nologo -DWIN32 -W3 -Oy- -Fd"zlib" %RtOpts% %BldOpts%
nmake -f win32/Makefile.vc.orig "CFLAGS=%CFLAGS%"
if errorlevel 1 exit /b 1

set StrLibPath=
call %CcBatDir%\sub\StrLibPath.bat %CcTgtLibPathType% %CcTgtLibDir% %VcVer% %Arch% %Rt% %Conf%
set TgtLibDir=%StrLibPath%
if not exist %TgtLibDir% mkdir %TgtLibDir%

if /I exist *.lib move *.lib %TgtLibDir%\
if /I exist *.dll move *.dll %TgtLibDir%\
if /I exist zlib.pdb move zlib.pdb %TgtLibDir%\
if /I exist zlib1.pdb move zlib1.pdb %TgtLibDir%\

if not "%HasTest%"=="1" goto TEST_SKIP
nmake -f win32/Makefile.vc.orig test
rem if errorlevel 1 exit /b 1
if exist foo.gz del foo.gz
if not exist test\exe mkdir test\exe
set TgtLibDir=test\exe\%Target%
if not exist %TgtLibDir% mkdir %TgtLibDir%
if /I exist *.exe move *.exe %TgtLibDir%\
if /I exist *.pdb move *.pdb %TgtLibDir%\
:TEST_SKIP

if exist *.obj del *.obj
if exist *.res del *.res
if exist *.manifest del *.manifest
if exist *.exp del *.exp

:Bld1_Exit
exit /b

:MkMakefileVC
%TinyReplStr% ++ "-base:0x5A4C0000 " " " -- win32\Makefile.msc > win32\Makefile.vc.orig
exit /b

:ERR
echo BUILD ERROR
exit /b 1

:END
endlocal
