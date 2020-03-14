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
set LibRootDir=%~dp0..

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

  if /I "%ARG:~0,11%"=="ZlibIncDir:" set ZlibIncDir=%ARG:~11%
  if /I "%ARG:~0,11%"=="ZlibLibDir:" set ZlibLibDir=%ARG:~11%
  if /I "%ARG:~0,10%"=="PngIncDir:"  set PngIncDir=%ARG:~10%
  if /I "%ARG:~0,10%"=="PngLibDir:"  set PngLibDir=%ARG:~10%

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

if "%ZlibIncDir%"=="" (
  for /f %%i in ('dir /b /on /ad %LibRootDir%\zlib*') do set ZlibIncDir=%LibRootDir%\%%i
)
if "%ZlibLibDir%"=="" (
  set ZlibLibDir=%ZlibIncDir%\lib
)

if "%PngIncDir%"=="" (
  for /f %%i in ('dir /b /on /ad %LibRootDir%\libpng*') do set PngIncDir=%LibRootDir%\%%i
)
if "%PngLibDir%"=="" (
  set PngLibDir=%PngIncDir%\lib
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
set ZlibSrcLibDir=%ZlibLibDir%\%Target%
set PngSrcLibDir=%PngLibDir%\%Target%

if "%RtType%"=="rtdll" (
  set RtOpts=-MD
) else (
  set RtOpts=-MT
)
if "%BldType%"=="dbg" (
  set BldOpts=-Zi
  set ldebug=/DEBUG
  set RtOpts=%RtOpts%d
) else (
  set BldOpts=-Ox -DNDEBUG
  set ldebug=/RELEASE
)

set CFLAGS= -nologo -W3 -D_CRT_SECURE_NO_DEPRECATE %BldOpts% %RtOpts%  -Iinclude -Iwin32\include -I%PngIncDir% -I%ZlibIncDir%
set LDFLAGS= /LIBPATH:%PngSrcLibDir% /LIBPATH:%ZlibSrcLibDir% /LIBPATH:win32\msvc libpng.lib zlib.lib

set CFLAGS_DEMO= -nologo -W3 -D_CRT_SECURE_NO_DEPRECATE %BldOpts% %RtOpts%  -Iinclude -Iwin32\include -D__WIN32__
set LDFLAGS_DEMO2=/link /LIBPATH:. /LIBPATH:win32\msvc /LIBPATH:%PngSrcLibDir% /LIBPATH:%ZlibSrcLibDir% libhpdf.lib libpng.lib zlib.lib

nmake -f script\Makefile.msvc clean

nmake -f script\Makefile.msvc all  "CFLAGS=%CFLAGS%" "LDFLAGS=%LDFLAGS%" "CFLAGS_DEMO=%CFLAGS_DEMO%" "LDFLAGS_DEMO2=%LDFLAGS_DEMO2%"

if not "%HasTest%"=="1" goto TEST_SKIP
nmake -f script\Makefile.msvc demo "CFLAGS=%CFLAGS%" "LDFLAGS=%LDFLAGS%" "CFLAGS_DEMO=%CFLAGS_DEMO%" "LDFLAGS_DEMO2=%LDFLAGS_DEMO2%"

pushd demo
if not exist exe mkdir exe
set DstDir=exe\%Target%
if not exist %DstDir% mkdir %DstDir%
if exist *.exe move *.exe %DstDir%\
if exist *.pdb move *.pdb %DstDir%\
if exist *.exe.pdf move *.exe.pdf %DstDir%\
if exist *.exe.manifest move *.exe.manifest %DstDir%\
popd
:TEST_SKIP

set DstDir=%LibDir%\%Target%
if not exist %DstDir% mkdir %DstDir%
if exist *.lib move *.lib %DstDir%\
rem if exist *.dll move *.dll %DstDir%\
rem if exist *.pdb move *.pdb %DstDir%\

rem nmake -f script\Makefile.msvc demo "CFLAGS=%CFLAGS%" "LDFLAGS=%LDFLAGS%" "CFLAGS_DEMO=%CFLAGS_DEMO%" "LDFLAGS_DEMO2=%LDFLAGS_DEMO2%"
rem if errorlevel 1 goto :EOF

del /S *.obj *.exp *.dll.manifest *.ilk *.exe.manifest *.pdb

exit /b
