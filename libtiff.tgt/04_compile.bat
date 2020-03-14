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
set ZlibIncDir=
set ZlibLibDir=
set JpegIncDir=
set JpegLibDir=

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


if "%Arch%"=="" set Arch=Win32

if "%HasRtSta%%HasRtDll%"=="" (
  set HasRtSta=S
  set HasRtDll=L
)
if "%HasRel%%HasDbg%"=="" (
  set HasRel=r
  set HasDbg=d
)

if not exist libtiff\tif_config.h copy /b libtiff\tiffconf.vc.h libtiff\tif_config.h
if not exist libtiff\tif_config.h copy /b libtiff\tiffconf.vc.h port\tif_config.h

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
set OPTFLAGS=-EHsc -W3 -wd4996 -D_CRT_SECURE_NO_DEPRECATE %BldOpts% %RtOpts% -I=..\libtiff -I=libtiff -FI io.h
set OPTFLAGS=%OPTFLAGS% -DHAVE_SNPRINTF -DHAVE_STRTOL -DHAVE_STRTOUL -DHAVE_STRTOLL -DHAVE_STRTOULL -DHAVE_IO_H -DOLDNAME -DHAVE_STRING_H -DHAVE_SYS_TYPES_H -DHAVE_SEARCH_H -DHAVE_SETMODE
set OPTFLAGS=%OPTFLAGS% -DO_RDONLY=_O_RDONLY -DO_RDWR=_O_RDWR -DO_CREAT=_O_CREAT -DO_TRUNC=_O_TRUNC

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
