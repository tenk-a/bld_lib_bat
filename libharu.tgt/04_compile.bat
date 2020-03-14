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
set LibRootDir=%~dp0..

:ARG_LOOP
  set ARG=%1

  if "%ARG%"=="" goto ARG_LOOP_EXIT
  if /I "%ARG%"=="static"   set HasRtSta=S
  if /I "%ARG%"=="rtdll"    set HasRtDll=L
  if /I "%ARG%"=="release"  set HasRel=r
  if /I "%ARG%"=="debug"    set HasDbg=d
  if /I "%ARG%"=="test"     set HasTest=1

  shift
goto ARG_LOOP
:ARG_LOOP_EXIT

if "%HasRtSta%%HasRtDll%"=="" (
  set HasRtSta=S
  set HasRtDll=L
)
if "%HasRel%%HasDbg%"=="" (
  set HasRel=r
  set HasDbg=d
)

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

set ZlibSrcLibDir=%ZlibLibDir%\%Target%
set PngSrcLibDir=%PngLibDir%\%Target%

if "%Rt%"=="rtdll" (
  set RtOpts=-MD
) else (
  set RtOpts=-MT
)
if "%Conf%"=="debug" (
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

pause
nmake -f script\Makefile.msvc clean
pause

nmake -f script\Makefile.msvc all  "CFLAGS=%CFLAGS%" "LDFLAGS=%LDFLAGS%" "CFLAGS_DEMO=%CFLAGS_DEMO%" "LDFLAGS_DEMO2=%LDFLAGS_DEMO2%"
pause

if not "%HasTest%"=="1" goto TEST_SKIP
nmake -f script\Makefile.msvc demo "CFLAGS=%CFLAGS%" "LDFLAGS=%LDFLAGS%" "CFLAGS_DEMO=%CFLAGS_DEMO%" "LDFLAGS_DEMO2=%LDFLAGS_DEMO2%"
pause

pushd demo
if not exist *.exe goto TEST_SKIP
if not exist exe mkdir exe
set DstDir=exe\%Target%
if not exist %DstDir% mkdir %DstDir%
if exist *.exe move *.exe %DstDir%\
if exist *.pdb move *.pdb %DstDir%\
if exist *.exe.pdf move *.exe.pdf %DstDir%\
if exist *.exe.manifest move *.exe.manifest %DstDir%\
popd
:TEST_SKIP

set DstDir=%CcTgtLibDir%\%Target%
if not exist %DstDir% mkdir %DstDir%
if exist *.lib move *.lib %DstDir%\
pause
rem if exist *.dll move *.dll %DstDir%\
rem if exist *.pdb move *.pdb %DstDir%\

rem nmake -f script\Makefile.msvc demo "CFLAGS=%CFLAGS%" "LDFLAGS=%LDFLAGS%" "CFLAGS_DEMO=%CFLAGS_DEMO%" "LDFLAGS_DEMO2=%LDFLAGS_DEMO2%"
rem if errorlevel 1 goto :EOF

del /S *.obj *.exp *.dll.manifest *.ilk *.exe.manifest *.pdb

exit /b
