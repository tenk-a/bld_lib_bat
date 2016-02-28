@echo off
rem Compile libbz2 for vc
rem bld1_bzip2 [x86/x64] [debug/release] [static/rtdll] [libdir:DEST_DIR]
rem ex)
rem cd bzip2-1.0.6
rem ..\bld_lib_bat\bld1_bzip2.bat x64
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

nmake -f makefile.msc CFLAGS=" -DWIN32 %RtOpts% %BldOpts% -D_FILE_OFFSET_BITS=64 -nologo"

set DstDir=%LibDir%\%Target%
if not exist %DstDir% mkdir %DstDir%
if not exist %DstDir%\exe mkdir %DstDir%\exe

del *.obj *.rb2 *.tst
move *.lib %DstDir%\
move *.pdb %DstDir%\exe\
move *.exe %DstDir%\exe\

if "%LibCopyDir%"=="" goto ENDIF_LibCopyDir
if not exist %LibCopyDir% mkdir %LibCopyDir%
if not exist %LibCopyDir%\%Target% mkdir %LibCopyDir%\%Target%
if exist %DstDir%\*.lib copy %DstDir%\*.lib %LibCopyDir%\%Target%
:ENDIF_LibCopyDir

exit /b
