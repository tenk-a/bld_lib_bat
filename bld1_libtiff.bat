rem @echo off
rem Compile libtiff for vc
rem usage: bld1_tiff [win32/x64] [debug/release] [static/rtdll] [libdir:DEST_DIR]
rem ex)
rem cd tiff-4.0.3
rem ..\bld_lib_bat\bld1_tiff.bat
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

set HasRel=
set HasDbg=
set HasRtSta=
set HasRtDll=
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
  if /I "%ARG:~0,8%"=="jpeginc:"    set JpegIncDir=%ARG:~8%
  if /I "%ARG:~0,8%"=="jpeglib:"    set JpegLibDir=%ARG:~8%

  shift
goto ARG_LOOP

:ARG_LOOP_EXIT

if "%ZlibIncDir%"=="" (
  for /D %%i in (%CD%\..\zlib*.*) do set ZlibIncDir=%%i
)
if "%ZlibLibDir%"=="" (
  set ZlibLibDir=%ZlibIncDir%\lib
)
if "%JpegIncDir%"=="" (
  for /D %%i in (%CD%\..\mozjpeg*.*) do set JpegIncDir=%%i
)
if "%JpegIncDir%"=="" (
  for /D %%i in (%CD%\..\libjpeg-turbo*.*) do set JpegIncDir=%%i
)
if "%JpegIncDir%"=="" (
  for /D %%i in (%CD%\..\jpeg*.*) do set JpegIncDir=%%i
)
if "%JpegLibDir%"=="" (
  set JpegLibDir=%JpegIncDir%\lib
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
  if /I not "%PATH:Microsoft Visual Studio 14.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 13.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
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
set OPTFLAGS=-EHsc -W3 -wd4996 -D_CRT_SECURE_NO_DEPRECATE %BldOpts% %RtOpts%

set ZLIB_ARGS=
if exist %ZlibIncDir%\zlib.h (
  set "ZLIB_ARGS= ZIP_SUPPORT=1 ZLIBDIR=%ZlibIncDir% ZLIB_INCLUDE=-I%ZlibIncDir% ZLIB_LIB=%ZlibLibDir%\%Target%\zlib.lib"
)

set JPEG_ARGS=
if exist %JpegIncDir%\jpeglib.h (
  set "JPEG_ARGS=JPEG_SUPPORT=1 JPEGDIR=%JpegIncDir% JPEG_INCLUDE=-I%JpegIncDir% JPEG_LIB=%JpegLibDir%\%Target%\libjpeg.lib"
)
if exist %JpegIncDir%\turbojpeg.h (
  set "JPEG_ARGS=JPEG_SUPPORT=1 JPEGDIR=%JpegIncDir% JPEG_INCLUDE=-I%JpegIncDir% JPEG_LIB=%JpegLibDir%\%Target%\jpeg-static.lib"
)

cd port
if exist libport.lib del libport.lib
del *.obj *.exp *.dll.manifest *.ilk
nmake -f Makefile.vc "OPTFLAGS=%OPTFLAGS%"
if errorlevel 1 goto :EOF
del *.obj *.exp *.dll.manifest *.ilk
cd ..

cd libtiff
if exist libtiff.lib del libtiff.lib
del *.obj *.exp *.dll.manifest *.ilk
nmake -f Makefile.vc "OPTFLAGS=%OPTFLAGS%" %ZLIB_ARGS% %JPEG_ARGS%
rem if errorlevel 1 goto :EOF
del *.obj *.exp *.dll.manifest *.ilk
del %VcVer%.pdb
cd ..

set DstDir=%LibDir%\%Target%

if not exist %DstDir% mkdir %DstDir%
if exist libtiff\*.lib move libtiff\*.lib %DstDir%\
if exist libtiff\*.dll move libtiff\*.dll %DstDir%\
if exist libtiff\*.pdb move libtiff\*.pdb %DstDir%\

exit /b
