@echo off
rem Compile libtiff for vc
rem usage: bld1_tiff [win32/x64] [debug/release] [static/rtdll] [libdir:DEST_DIR] [libcopy:DEST_DIR]
rem ex)
rem cd tiff-4.0.3
rem ..\bld_lib_bat\bld1_tiff.bat
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

set ZlibIncDir=
set ZlibLibDir=
set JpegIncDir=
set JpegLibDir=
set JpegTurbo=0

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

  if /I "%ARG:~0,8%"=="zlibinc:"    set ZlibIncDir=%ARG:~8%
  if /I "%ARG:~0,8%"=="zliblib:"    set ZlibLibDir=%ARG:~8%
  if /I "%ARG:~0,8%"=="jpeginc:"    set JpegIncDir=%ARG:~8%
  if /I "%ARG:~0,8%"=="jpeglib:"    set JpegLibDir=%ARG:~8%

  shift
goto ARG_LOOP

:ARG_LOOP_EXIT

if "%Arch%"=="" (
  if /I not "%PATH:Microsoft Visual Studio 14.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
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
if errorlevel 1 goto :EOF
del *.obj *.exp *.dll.manifest *.ilk
cd ..

set DstDir=%LibDir%\%Target%

if not exist %DstDir% mkdir %DstDir%
if exist libtiff\*.lib move libtiff\*.lib %DstDir%\
if exist libtiff\*.dll move libtiff\*.dll %DstDir%\
if exist libtiff\*.pdb move libtiff\*.pdb %DstDir%\

if "%LibCopyDir%"=="" goto ENDIF_LibCopyDir
if not exist %LibCopyDir% mkdir %LibCopyDir%
if not exist %LibCopyDir%\%Target% mkdir %LibCopyDir%\%Target%

if exist %DstDir%\*.lib copy %DstDir%\*.lib %LibCopyDir%\%Target%
if exist %DstDir%\*.dll copy %DstDir%\*.dll %LibCopyDir%\%Target%
if exist %DstDir%\*.pdb copy %DstDir%\*.pdb %LibCopyDir%\%Target%

:ENDIF_LibCopyDir
exit /b
