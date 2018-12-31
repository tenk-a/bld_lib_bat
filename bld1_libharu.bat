rem @echo off
rem Compile libharu for vc
rem usage: bld1_libharu [win32/x64] [debug/release] [static/rtdll] [libdir:DEST_DIR] [libcopy:DEST_DIR]
rem ex)
rem cd libharu-RELEASE_2_3_0
rem ..\bld_lib_bat\bld1_libharu.bat
rem
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
set LibRootDir=%~dp0..

set ZlibIncDir=
set ZlibLibDir=
set PngIncDir=
set PngLibDir=

set HasRel=
set HasDbg=
set HasRtSta=
set HasRtDll=
set HasTest=
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

  if /I "%1"=="test"     set HasTest=1

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

  if /I "%ARG:~0,8%"=="zlibinc:"    set ZlibIncDir=%ARG:~8%
  if /I "%ARG:~0,8%"=="zliblib:"    set ZlibLibDir=%ARG:~8%
  if /I "%ARG:~0,8%"=="pnginc:"     set PngIncDir=%ARG:~7%
  if /I "%ARG:~0,8%"=="pnglib:"     set PngLibDir=%ARG:~7%

  shift
goto ARG_LOOP
:ARG_LOOP_EXIT

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
