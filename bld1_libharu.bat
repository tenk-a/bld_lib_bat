
rem @echo off
rem Compile libharu for vc
rem usage: bld1_libharu [x86/x64] [debug/release] [static/rtdll] [libdir:DEST_DIR] [libcopy:DEST_DIR]
rem ex)
rem cd libharu-RELEASE_2_3_0
rem ..\bld_lib_bat\bld1_libharu.bat
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
set LibRootDir=%~dp0..

set ZlibDir=
set PngDir=

set HasRel=
set HasDbg=
set HasRtSta=
set HasRtDll=

:ARG_LOOP
  if "%1"=="" goto ARG_LOOP_EXIT

  if /I "%1"=="x86"      set Arch=x86
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

  if /I "%ARG:~0,8%"=="zlibdir:" set ZlibDir=%ARG:~8%
  if /I "%ARG:~0,7%"=="pngdir:"  set PngDir=%ARG:~7%

  shift
goto ARG_LOOP
:ARG_LOOP_EXIT

if "%ZlibDir%"=="" (
  for /f %%i in ('dir /b /on /ad %LibRootDir%\zlib*') do set ZlibDir=%LibRootDir%\%%i
)
set ZlibIncDir=%ZlibDir%
set ZlibLibDir=%ZlibDir%\lib
if "%ZlibDir%"=="misc" (
  set ZlibIncDir=..\misc_inc\zlib
  set ZlibLibDir=..\misc_lib
)

if "%PngDir%"=="" (
  for /f %%i in ('dir /b /on /ad %LibRootDir%\lpng*') do set PngDir=%LibRootDir%\%%i
)
set PngIncDir=%PngDir%
set PngLibDir=%PngDir%\lib
if "%PngDir%"=="misc" (
  set PngIncDir=..\misc_inc\png
  set PngLibDir=..\misc_lib
)

if "%Arch%"=="" (
  if /I not "%PATH:Microsoft Visual Studio 13.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 12.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 11.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 10.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 9.0\VC\BIN\amd64=%"=="%PATH%"  set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 8\VC\BIN\amd64=%"=="%PATH%"    set Arch=x64
)
if "%Arch%"=="" set Arch=x86

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
set LDFLAGS= /LIBPATH:%PngSrcLibDir% /LIBPATH:%ZlibSrcLibDir% /LIBPATH:win32\msvc libpng.lib zlib_a.lib

set CFLAGS_DEMO= -nologo -W3 -D_CRT_SECURE_NO_DEPRECATE %BldOpts% %RtOpts%  -Iinclude -Iwin32\include -D__WIN32__
set LDFLAGS_DEMO2=/link /LIBPATH:. /LIBPATH:win32\msvc /LIBPATH:%PngSrcLibDir% /LIBPATH:%ZlibSrcLibDir% libhpdf.lib libpng.lib zlib.lib

nmake -f script\Makefile.msvc clean

nmake -f script\Makefile.msvc demo "CFLAGS=%CFLAGS%" "LDFLAGS=%LDFLAGS%" "CFLAGS_DEMO=%CFLAGS_DEMO%" "LDFLAGS_DEMO2=%LDFLAGS_DEMO2%"
if errorlevel 1 goto :EOF
del /S *.obj *.exp *.dll.manifest *.ilk

move *.lib lib\%Target%\
set DstDir=%LibDir%\%Target%

if not exist %DstDir% mkdir %DstDir%
if exist *.lib move *.lib %DstDir%\
if exist *.dll move *.dll %DstDir%\
if exist *.pdb move *.pdb %DstDir%\

if "%LibCopyDir%"=="" goto ENDIF_LibCopyDir
if not exist %LibCopyDir% mkdir %LibCopyDir%
if not exist %LibCopyDir%\%Target% mkdir %LibCopyDir%\%Target%
if exist %DstDir%\*.lib copy %DstDir%\*.lib %LibCopyDir%\%Target%
if exist %DstDir%\*.dll copy %DstDir%\*.dll %LibCopyDir%\%Target%
if exist %DstDir%\*.pdb copy %DstDir%\*.pdb %LibCopyDir%\%Target%
:ENDIF_LibCopyDir

exit /b
