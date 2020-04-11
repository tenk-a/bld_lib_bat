rem @echo on
rem @echo off
rem This batch-file license: boost software license version 1.0
setlocal

set VcVer=%1
shift
set Arch=%1
shift
if "%Arch%"=="" set Arch=Win32

set HasRel=
set HasDbg=
set HasRtSta=
set HasRtDll=
set HasTest=

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

set CurDir=%CD%
if not exist %CurDir%\%CcTgtLibDir% mkdir %CurDir%\%CcTgtLibDir%

if "%HasRtSta%%HasRel%"=="Sr" call :Bld1 static release
if "%HasRtSta%%HasDbg%"=="Sd" call :Bld1 static debug
if "%HasRtDll%%HasRel%"=="Lr" call :Bld1 rtdll  release
if "%HasRtDll%%HasDbg%"=="Ld" call :Bld1 rtdll  debug

goto END


:Bld1
set Rt=%1
set Conf=%2

set PlatformArch=
if /I "%VcVer%%Arch%"=="vc90Win32"  set PlatformArch=-G "Visual Studio 9 2008"
if /I "%VcVer%%Arch%"=="vc90x64"    set PlatformArch=-G "Visual Studio 9 2008 Win64"
if /I "%VcVer%%Arch%"=="vc100Win32" set PlatformArch=-G "Visual Studio 10 2010"
if /I "%VcVer%%Arch%"=="vc100x64"   set PlatformArch=-G "Visual Studio 10 2010 Win64"
if /I "%VcVer%%Arch%"=="vc110Win32" set PlatformArch=-G "Visual Studio 11 2012"
if /I "%VcVer%%Arch%"=="vc110x64"   set PlatformArch=-G "Visual Studio 11 2012 Win64"
if /I "%VcVer%%Arch%"=="vc120Win32" set PlatformArch=-G "Visual Studio 12 2013"
if /I "%VcVer%%Arch%"=="vc120x64"   set PlatformArch=-G "Visual Studio 12 2013 Win64"
if /I "%VcVer%%Arch%"=="vc140Win32" set PlatformArch=-G "Visual Studio 14 2015"
if /I "%VcVer%%Arch%"=="vc140x64"   set PlatformArch=-G "Visual Studio 14 2015 Win64"
if /I "%VcVer%%Arch%"=="vc141Win32" set PlatformArch=-G "Visual Studio 15 2017"
if /I "%VcVer%%Arch%"=="vc141x64"   set PlatformArch=-G "Visual Studio 15 2017 Win64"
if /I "%VcVer%%Arch%"=="vc142Win32" set PlatformArch=-G "Visual Studio 16 2019"
if /I "%VcVer%%Arch%"=="vc142x64"   set PlatformArch=-G "Visual Studio 16 2019" -A x64

rem echo %CcTgtLibPathType%
set StrLibPath=
call %CcBatDir%\sub\StrLibPath.bat %CcTgtLibPathType% %CurDir%\%CcTgtBldDir% %VcVer% %Arch% %Rt%
set TgtBldDir=%StrLibPath%
if not exist %TgtBldDir% mkdir %TgtBldDir%

pushd %TgtBldDir%

rem ZLIB_LIBRARY=%ZlibDir% ZLIB_INCLUDE_DIR=%ZlibIncDir% PNG_PNG_INCLUDE_DIR=%PngIncDir% PNG_ JPEG_LIBRARY=%JpegDir% JPEG_INCLUDE_DIR=%JpegIncDir%
if not exist FLTK.sln (
  "%CcCMakeDir%\cmake.exe" ../.. %PlatformArch%
  if "%Rt%"=="static" call :ReplaceMDtoMT
)

msbuild FLTK.sln /t:Rebuild /p:Configuration=%Conf% /p:Platform=%Arch%

popd

set StrLibPath=
call %CcBatDir%\sub\StrLibPath.bat %CcTgtLibPathType% %CurDir%\%CcTgtLibDir% %VcVer% %Arch% %Rt% %Conf%
set TgtLibDir=%StrLibPath%
if not exist %TgtLibDir% mkdir %TgtLibDir%

copy /b %TgtBldDir%\lib\%Conf%\*.lib %TgtLibDir%\

exit /b


:ReplaceMDtoMT
for /r %%i in (*.vcxproj src\*.vcxproj) do (
  if exist %%i call :Rep1MDtoMT %%i
)
exit /b

:Rep1MDtoMT
%TinyReplStr% -x ++ MultiThreadedDLL MultiThreaded MultiThreadedDebugDLL MultiThreadedDebug -- %1
exit /b


:END
endlocal
