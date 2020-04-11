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
if /I "%VcVer%%Arch%"=="vc142Win32" set PlatformArch=-G "Visual Studio 16 2019" -A Win32
if /I "%VcVer%%Arch%"=="vc142x64"   set PlatformArch=-G "Visual Studio 16 2019" -A x64
rem echo "%PlatformArch%"

set BaseDir=%CD%

if "%HasRtDll%"=="L" call :Bld1 rtdll
if not errorlevel 0 exit /b 1
if "%HasRtSta%"=="S" call :Bld1 static
if not errorlevel 0 exit /b 1
if "%HasDll%"=="D"   call :Bld1 dll
if not errorlevel 0 exit /b 1

goto END


:Bld1
set Rt=%1
rem set Conf=%2

call %CcBatDir%\sub\StrLibPath.bat %CcTgtLibPathType% %CcTgtBldDir% %VcVer% %Arch% %Rt%
set TgtBldDir=%StrLibPath%
if not exist %TgtBldDir% mkdir %TgtBldDir%


pushd %TgtBldDir%

if not exist LLGL.sln (
  CMake %PlatformArch% %BaseDir%
  if %Rt%==static call :ReplaceMDtoMT
)

if not "%HasRel%"=="r" goto BLD1_SKIP_R
  msbuild LLGL.sln /t:Rebuild /p:Configuration=release /p:Platform=%Arch% /maxcpucount
  if not errorlevel 0 exit /b 1
  set Conf=release
  set StrLibPath=
  call %CcBatDir%\sub\StrLibPath.bat %CcTgtLibPathType% %BaseDir%\%CcTgtLibDir% %VcVer% %Arch% %Rt% %Conf%
  set TgtLibDir=%StrLibPath%
  if not exist %TgtLibDir% mkdir %TgtLibDir%
  if exist build\Release xcopy build\Release %TgtLibDir% /R /Y /I /K /E
:BLD1_SKIP_R

if not "%HasDbg%"=="d" goto BLD1_SKIP_D
  msbuild LLGL.sln /p:Configuration=debug   /p:Platform=%Arch% /maxcpucount
  if not errorlevel 0 exit /b 1
  set Conf=debug
  set StrLibPath=
  call %CcBatDir%\sub\StrLibPath.bat %CcTgtLibPathType% %BaseDir%\%CcTgtLibDir% %VcVer% %Arch% %Rt% %Conf%
  set TgtLibDir=%StrLibPath%
  if not exist %TgtLibDir% mkdir %TgtLibDir%
  if exist build\debug xcopy build\debug %TgtLibDir%  /R /Y /I /K /E
:BLD1_SKIP_D

popd

exit /b

:ReplaceMDtoMT
for /r %%i in (*.vcxproj ) do if exist %%i call :Rep1MDtoMT %%i
exit /b

:Rep1MDtoMT
%TinyReplStr% -x ++ MultiThreadedDLL MultiThreaded MultiThreadedDebugDLL MultiThreadedDebug -- %1
exit /b


:ERR
echo BUILD ERROR
exit /b 1

:END
endlocal
