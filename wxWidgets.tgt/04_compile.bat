@rem Compile wxWidgets for vc
@rem This batch-file license: boost software license version 1.0
setlocal

set VcVer=%1
shift
set Arch=%1
shift

set StrRtSta=_static
set StrRtDll=
set StrDll=_dll

set HasRel=
set HasDbg=
set HasRtSta=
set HasRtDll=
set HasDll=
set HasTest=

set CppOpt="USE_OPENGL=1"

:ARG_LOOP
  set ARG=%1
  if "%ARG%"=="" goto ARG_LOOP_EXIT

  if /I "%ARG%"=="release" set HasRel=r
  if /I "%ARG%"=="debug"  set HasDbg=d
  if /I "%ARG%"=="static" set HasRtSta=S
  if /I "%ARG%"=="rtdll"  set HasRtDll=L
  if /I "%ARG%"=="dll"    set HasDll=D

  if /I "%ARG%"=="test"	  set HasTest=1

  shift
goto ARG_LOOP
:ARG_LOOP_EXIT

if "%HasRtSta%%HasRtDll%%HasDll%"=="" (
  set HasRtSta=S
  set HasRtDll=L
)
if "%HasRel%%HasDbg%"=="" (
  set HasRel=r
  set HasDbg=d
)

@rem if "%HasRtSta%%HasRel%"=="Sr" call :Bld1 "RUNTIME_LIBS=static"  static relese  lib
@rem if "%HasRtSta%%HasDbg%"=="Sd" call :Bld1 "RUNTIME_LIBS=static"  static debug   lib
@rem if "%HasRtDll%%HasRel%"=="Lr" call :Bld1 "RUNTIME_LIBS=dynamic" rtdll  release lib
@rem if "%HasRtDll%%HasDbg%"=="Ld" call :Bld1 "RUNTIME_LIBS=dynamic" rtdll  debug   lib
@rem if "%HasDll%%HasRel%"=="Dr"   call :Bld1 "SHARED=1"             dll    release dll
@rem if "%HasDll%%HasDbg%"=="Dd"   call :Bld1 "SHARED=1"             dll    debug   dll

if "%HasRtSta%"=="S" call :Bld1 "RUNTIME_LIBS=static"  static lib
if "%HasRtDll%"=="L" call :Bld1 "RUNTIME_LIBS=dynamic" rtdll  lib
if "%HasDll%"=="D"   call :Bld1 "SHARED=1"             dll    dll

rem goto TEST_SKIP
if "%HasTest%"==""  goto TEST_SKIP
if "%HasRtSta%"=="S" call :Test "RUNTIME_LIBS=static"  static
if "%HasRtDll%"=="L" call :Test "RUNTIME_LIBS=dynamic" rtdll
if "%HasDll%"=="D"   call :Test "SHARED=1"             dll
:TEST_SKIP
endlocal
goto :EOF

:Bld1
set RtOpt=%~1
set Rt=%2
set TargetLibName=%3
set Conf=release

set TargetOld=vc_
if "%Arch%"=="x64" set TargetOld=%TargetOld%%Arch%_
set TargetOld=%TargetOld%%TargetLibName%


set StrLibPath=
call %CcBatDir%\sub\StrLibPath.bat %CcTgtLibPathType% _ %VcVer% %Arch% %Rt% release
set TgtDir=%CcTgtLibDir%\%StrLibPath%
if not exist %TgtDir% mkdir %TgtDir%

set CpuOpt=
if "%Arch%"=="x64" set "CpuOpt=TARGET_CPU=X64"

set CFLAGSSET=
rem if /I "%CcName%"=="vc140" set "CFLAGSSET=CFLAGS=-Dsnprintf=snprintf"

rem goto BLD1_SKIP2
cd .\build\msw
nmake -f makefile.vc %CpuOpt% %RtOpt% %CppOpt% %CFLAGSSET% BUILD=%Conf% clean
nmake -f makefile.vc %CpuOpt% %RtOpt% %CppOpt% %CFLAGSSET% BUILD=%Conf%
rem nmake -f makefile.vc %CpuOpt% %RtOpt% %CppOpt% %CFLAGSSET% BUILD=debug   clean
rem nmake -f makefile.vc %CpuOpt% %RtOpt% %CppOpt% %CFLAGSSET% BUILD=debug
cd ..\..
:BLD1_SKIP2

if not lib\%TargetOld%==%TgtDir% (
  move lib\%TargetOld% %TgtDir%
)

set StrLibPath=
call %CcBatDir%\sub\StrLibPath.bat %CcTgtLibPathType% _ %VcVer% %Arch% %Rt% debug
set TgtDirD=%CcTgtLibDir%\%StrLibPath%
if not exist %TgtDirD% mkdir %TgtDirD%
xcopy %TgtDir% %TgtDirD% /R /Y /I /K /E

xcopy %TgtDir%\mswu include\mswu /R /Y /I /K /E

exit /b


:Test
set RtOpt=%~1
set Rt=%2
set Conf=release

set StrLibPath=
call %CcBatDir%\sub\StrLibPath.bat %CcTgtLibPathType% _ %VcVer% %Arch% %Rt% %Conf%
set LibDir=%CcTgtLibDir%\%StrLibPath%

set CpuOpt=
if "%Arch%"=="x64" set "CpuOpt=TARGET_CPU=X64"

set CFLAGSSET=
rem if /I "%CcName%"=="vc140" set "CFLAGSSET=CFLAGS=-Dsnprintf=snprintf"
set CFLAGSSET=%CFLAGSSET% 

set LIBDIRNAME=..\..\%LibDir%

rem goto TEST_SKIP2
pushd samples
nmake -f makefile.vc %CpuOpt% %RtOpt% %CppOpt% %CFLAGSSET% BUILD=%Conf% clean
nmake -f makefile.vc %CpuOpt% %RtOpt% %CppOpt% %CFLAGSSET% BUILD=%Conf%
popd

:TEST_SKIP2

exit /b
