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

rem set ZlibIncDir=
rem set ZlibLibDir=
rem set JpegIncDir=
rem set JpegLibDir=

:ARG_LOOP
  set ARG=%1

  if "%ARG%"=="" goto ARG_LOOP_EXIT
  if /I "%ARG%"=="static"   set HasRtSta=S
  if /I "%ARG%"=="rtdll"    set HasRtDll=L
  if /I "%ARG%"=="release"  set HasRel=r
  if /I "%ARG%"=="debug"    set HasDbg=d
  if /I "%ARG%"=="test"     set HasTest=1

  rem if /I "%ARG:~0,8%"=="zlibinc:"    set ZlibIncDir=%ARG:~8%
  rem if /I "%ARG:~0,8%"=="zliblib:"    set ZlibLibDir=%ARG:~8%
  rem if /I "%ARG:~0,8%"=="jpeginc:"    set JpegIncDir=%ARG:~8%
  rem if /I "%ARG:~0,8%"=="jpeglib:"    set JpegLibDir=%ARG:~8%

  shift
goto ARG_LOOP
:ARG_LOOP_EXIT

goto SKIP2
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
:SKIP2

if "%HasRtSta%%HasRtDll%"=="" (
  set HasRtSta=S
  set HasRtDll=L
)
if "%HasRel%%HasDbg%"=="" (
  set HasRel=r
  set HasDbg=d
)

if not exist libtiff\tif_config.h copy /b libtiff\tif_config.vc.h libtiff\tif_config.h
if not exist libtiff\tif_config.h copy /b libtiff\tif_config.vc.h port\tif_config.h

if "%LibDir%"=="" set LibDir=lib
if not exist %LibDir% mkdir %LibDir%

if "%HasRtSta%%HasRel%"=="Sr" call :Bld1 static release
if "%HasRtSta%%HasDbg%"=="Sd" call :Bld1 static debug
if "%HasRtDll%%HasRel%"=="Lr" call :Bld1 rtdll  release
if "%HasRtDll%%HasDbg%"=="Ld" call :Bld1 rtdll  debug
endlocal
goto :EOF


:Bld1
set Rt=%1
set Conf=%2

set StrLibPath=
call %CcBatDir%\sub\StrLibPath.bat %CcTgtLibPathType% _ %VcVer% %Arch% %Rt% %Conf%
set Target=%StrLibPath%


if "%Rt%"=="rtdll" (
  set RtOpts=-MD
) else (
  set RtOpts=-MT
)
if "%Conf%"=="debug" (
  set BldOpts=-O2 -Zi
  set ldebug=/DEBUG
  set RtOpts=%RtOpts%d
) else (
  set BldOpts=-Ox -DNDEBUG
  set ldebug=/RELEASE
)
set OPTFLAGS=-EHsc -W3 -wd4996 -D_CRT_SECURE_NO_DEPRECATE %BldOpts% %RtOpts% -I=..\libtiff -I=libtiff -D_CRT_DECLARE_NONSTDC_NAMES -FI fcntl.h
set OPTFLAGS=%OPTFLAGS% -DHAVE_SNPRINTF -DHAVE_STRTOL -DHAVE_STRTOUL -DHAVE_STRTOLL -DHAVE_STRTOULL -DHAVE_IO_H -DOLDNAME -DHAVE_STRING_H -DHAVE_SYS_TYPES_H -DHAVE_SEARCH_H -DHAVE_SETMODE
rem set OPTFLAGS=%OPTFLAGS% -DO_RDONLY=_O_RDONLY -DO_RDWR=_O_RDWR -DO_CREAT=_O_CREAT -DO_TRUNC=_O_TRUNC

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
if errorlevel 1 (
  pause
  goto :EOF
)
del *.obj *.exp *.dll.manifest *.ilk
cd ..

cd libtiff
if exist libtiff.lib del libtiff.lib
del *.obj *.exp *.dll.manifest *.ilk
nmake -f Makefile.vc "OPTFLAGS=%OPTFLAGS%" %ZLIB_ARGS% %JPEG_ARGS%
if errorlevel 1 (
  pause
  goto :EOF
)
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
