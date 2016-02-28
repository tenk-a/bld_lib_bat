rem @echo off
rem Compile libjpeg for vc
rem usage: bld1_libjpeg [x86/x64] [debug/release] [static/rtdll] [libdir:DEST_DIR]
rem ex)
rem cd libjpeg-1.2.8
rem ..\bld_lib_bat\bld1_libjpeg.bat x64 static libdir:d:\mylib
rem
rem This batch-file license: boost software license version 1.0
setlocal

set Arch=%CcArch%
set LibDir=%CcLibDir%
set LibCopyDir=
set StrPrefix=%CcLibPrefix%
set StrRel=%CcLibStrRelease%
set StrDbg=%CcLibStrDebug%
set StrRtSta=%CcLibStrStatic%
set StrRtDll=%CcLibStrRtDll%

set HasRel=
set HasDbg=
set HasRtSta=
set HasRtDll=

set LibArchX86=%CcLibArchX86%
if "%LibArchX86%"=="" set LibArchX86=Win32

:ARG_LOOP
  if "%1"=="" goto ARG_LOOP_EXIT

  if /I "%1"=="x86"      set Arch=%LibArchX86%
  if /I "%1"=="win32"    set Arch=%LibArchX86%
  if /I "%1"=="x64"      set Arch=x64

  if /I "%1"=="static"   set HasRtSta=S
  if /I "%1"=="rtsta"    set HasRtSta=S
  if /I "%1"=="rtdll"    set HasRtDll=L

  if /I "%1"=="release"  set HasRel=r
  if /I "%1"=="debug"    set HasDbg=d

  set ARG=%1
  if /I "%ARG:~0,8%"=="LibCopy:"    set LibCopyDir=%ARG:~8%
  if /I "%ARG:~0,7%"=="LibDir:"     set LibDir=%ARG:~7%
  if /I "%ARG:~0,10%"=="LibPrefix:" set StrPrefix=%ARG:~10%
  if /I "%ARG:~0,9%"=="LibRtSta:"   set StrRtSta=%ARG:~9%
  if /I "%ARG:~0,9%"=="LibRtDll:"   set StrRtDll=%ARG:~9%
  if /I "%ARG:~0,7%"=="LibRel:"     set StrRel=%ARG:~7%
  if /I "%ARG:~0,7%"=="LibDbg:"     set StrDbg=%ARG:~7%

  shift
goto ARG_LOOP
:ARG_LOOP_EXIT

if "%Arch%"=="" (
  if /I not "%PATH:Microsoft Visual Studio 13.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 12.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 11.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 10.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 9.0\VC\BIN\amd64=%"=="%PATH%"  set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 8\VC\BIN\amd64=%"=="%PATH%"    set Arch=x64
)
if "%Arch%"=="" set Arch=%LibArchX86%

if "%HasRtSta%%HasRtDll%"=="" (
  set HasRtSta=S
  set HasRtDll=L
)
if "%HasRel%%HasDbg%"=="" (
  set HasRel=r
  set HasDbg=d
)

if "%StrRel%%StrDbg%"==""     set StrDbg=_debug
if "%StrRtSta%%StrRtDll%"=="" set StrRtSta=_static

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

nmake -f makefile.vc "cflags=%cflags%" "cdebug=%BldOpts%" "cvars=%RtOpts%" "conlflags=%conlflags%" "conlibs=%conlibs%" "ldebug=%ldebug%"
if errorlevel 1 goto :EOF

rem nmake -f makefile.vc test
rem if errorlevel 1 goto :EOF

del *.obj

set DstDir=%LibDir%\%Target%

if not exist %DstDir% mkdir %DstDir%
if exist *.lib move *.lib %DstDir%\

if not exist %DstDir%\exe mkdir %DstDir%\exe
if exist *.pdb move *.pdb %DstDir%\exe
if exist *.exe move *.exe %DstDir%\exe

if "%LibCopyDir%"=="" goto ENDIF_LibCopyDir
if not exist %LibCopyDir% mkdir %LibCopyDir%
if not exist %LibCopyDir%\%Target% mkdir %LibCopyDir%\%Target%
if exist %DstDir%\*.lib copy %DstDir%\*.lib %LibCopyDir%\%Target%
:ENDIF_LibCopyDir

exit /b
