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

if "%LibDir%"=="" set LibDir=lib
if not exist %LibDir% mkdir %LibDir%

if "%HasRtSta%%HasRel%"=="Sr" call :Bld1 static release %StrPrefix%%Arch%%StrRtSta%%StrRel%
if errorlevel 1 goto ERR

if "%HasRtSta%%HasDbg%"=="Sd" call :Bld1 static debug   %StrPrefix%%Arch%%StrRtSta%%StrDbg%
if errorlevel 1 goto ERR

if "%HasRtDll%%HasRel%"=="Lr" call :Bld1 rtdll  release %StrPrefix%%Arch%%StrRtDll%%StrRel%
if errorlevel 1 goto ERR

if "%HasRtDll%%HasDbg%"=="Ld" call :Bld1 rtdll  debug   %StrPrefix%%Arch%%StrRtDll%%StrDbg%
if errorlevel 1 goto ERR

goto END


:Bld1
set RtType=%1
set BldType=%2
set Target=%3




if "%RtType%"=="rtdll" (
  set RtOpts=-MD
) else (
  set RtOpts=-MT
)
if "%BldType%"=="debug" (
  set BldOpts=-O2 -Zi
  set RtOpts=%RtOpts%d
) else (
  set BldOpts=-O2 -DNDEBUG
)

set CFLAGS=-nologo -DWIN32 -W3 -Oy- -Fd"zlib" %RtOpts% %BldOpts%
nmake -f win32/Makefile.msc "CFLAGS=%CFLAGS%"
if errorlevel 1 exit /b 1

set DstDir=%LibDir%\%Target%
if not exist %DstDir% mkdir %DstDir%

if /I exist *.lib move *.lib %DstDir%\
if /I exist *.dll move *.dll %DstDir%\
if /I exist zlib.pdb move zlib.pdb %DstDir%\
if /I exist zlib1.pdb move zlib1.pdb %DstDir%\

if not "%HasTest%"=="1" goto TEST_SKIP
nmake -f win32/Makefile.msc test
rem if errorlevel 1 exit /b 1
if exist foo.gz del foo.gz
if not exist test\exe mkdir test\exe
set DstDir=test\exe\%Target%
if not exist %DstDir% mkdir %DstDir%
if /I exist *.exe move *.exe %DstDir%\
if /I exist *.pdb move *.pdb %DstDir%\
:TEST_SKIP

del *.obj *.res *.manifest *.exp

:Bld1_Exit
exit /b

:ERR
echo BUILD ERROR
exit /b 1

:END
endlocal
