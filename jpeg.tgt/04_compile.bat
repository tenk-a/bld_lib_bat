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

if not exist jconfig.h copy jconfig.vc jconfig.h
if not exist win32.mak (
  echo # dummy win32.mak >win32.mak
  echo cc=cl >>win32.mak
  echo link=link >>win32.mak
)

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

rem set "cflags=-c -D_X86_=1 -DWIN32 -D_WIN32 -W3 -D_WINNT -D_WIN32_WINNT=0x501 -DWINVER=0x501 -D_CRT_SECURE_NO_WARNINGS -wd4996"
set "cflags=-c -W3 -D_CRT_SECURE_NO_WARNINGS -wd4996"
rem set "conlflags=/INCREMENTAL:NO /NOLOGO -subsystem:console,5.01 -entry:mainCRTStartup"
rem set "conlflags=/INCREMENTAL:NO /NOLOGO -subsystem:console,5.01"
set "conlflags=/INCREMENTAL:NO /NOLOGO -subsystem:console,5.01"
rem set "conlibs=kernel32.lib ws2_32.lib mswsock.lib advapi32.lib"
set "conlibs=kernel32.lib advapi32.lib"

if "%RtType%"=="rtdll" (
  set RtOpts=-MD
) else (
  set RtOpts=-MT
)
if "%BldType%"=="dbg" (
  set BldOpts=-O2 -Zi
  set ldebug=/DEBUG
  set RtOpts=%RtOpts%d
) else (
  set BldOpts=-Ox -DNDEBUG
  set ldebug=/RELEASE
)

set MakeTgt=libjpeg.lib
if "%HasTest%"=="1" (
  set MakeTgt=all
)

nmake -f makefile.vc %MakeTgt% "cflags=%cflags%" "cdebug=%BldOpts%" "cvars=%RtOpts%" "conlflags=%conlflags%" "conlibs=%conlibs%" "ldebug=%ldebug%"
if errorlevel 1 goto :EOF

rem nmake -f makefile.vc test
rem if errorlevel 1 goto :EOF

if exist *.obj del *.obj

set DstDir=%LibDir%\%Target%

if not exist %DstDir% mkdir %DstDir%
if exist *.lib move *.lib %DstDir%\

if not exist %DstDir%\exe mkdir %DstDir%\exe
if exist *.pdb move *.pdb %DstDir%\exe
if exist *.exe move *.exe %DstDir%\exe

exit /b
