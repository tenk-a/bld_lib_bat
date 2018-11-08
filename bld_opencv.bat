@echo off
rem This batch-file license: boost software license version 1.0
setlocal

set TgtName=opencv
set TgtDir=
set SrcIncSubDir=include
set SrcLibSubDir=build
set DstIncSubDir=
set DstLibSubDir=
set HdrIsDir=1
set hdr1=opencv
set hdr2=opencv2
set hdr3=
set hdr4=
set hdr5=
set hdr6=
set hdr7=
set hdr8=
set hdr9=
set Arg=


call libs_config.bat
pushd ..

set HasX86=
set HasX64=
set HasRel=
set HasDbg=
set HasRtSta=
set HasRtDll=
set HasTest=
set NoCopy=
set NoBuild=
set VcVer=
set Arg=%Arg% %CcBld1Arg%
rem if "%SrcLibSubDir%"=="" set "SrcLibSubDir=%CcLibDir%"

:ARG_LOOP
  if "%1"=="" goto ARG_LOOP_EXIT

  if /I "%1"=="x86"      set HasX86=1
  if /I "%1"=="Win32"    set HasX86=1
  if /I "%1"=="x64"      set HasX64=1

  if /I "%1"=="static"   set HasRtSta=static
  if /I "%1"=="rtsta"    set HasRtSta=static
  if /I "%1"=="rtdll"    set HasRtDll=rtdll

  if /I "%1"=="release"  set HasRel=release
  if /I "%1"=="debug"    set HasDbg=debug

  if /I "%1"=="test"     set HasTest=test

  if /I "%1"=="vc71"     set VcVer=vc71
  if /I "%1"=="vc80"     set VcVer=vc80
  if /I "%1"=="vc90"     set VcVer=vc90
  if /I "%1"=="vc100"    set VcVer=vc100
  if /I "%1"=="vc110"    set VcVer=vc110
  if /I "%1"=="vc120"    set VcVer=vc120
  if /I "%1"=="vc130"    set VcVer=vc130
  if /I "%1"=="vc140"    set VcVer=vc140
  if /I "%1"=="vc141"    set VcVer=vc141

  if /I "%1"=="NoCopy"   set NoCopy=1
  if /I "%1"=="NoBuild"  set NoBuild=1
  set A=%1
  if /I "%A:~0,4%"=="src:" set TgtDir=%A:~4%

  shift
goto ARG_LOOP
:ARG_LOOP_EXIT
set A=

if "%HasX86%%HasX64%"=="" (
  set HasX86=%CcHasX86%
  set HasX64=%CcHasX64%
)

set LibPrefix=%VcVer%_
if "%VcVer%"=="" (
  set VcVer=%CcName%
  set LibPrefix=%CcLibPrefix%
)

if "%TgtDir%"=="" (
  for /f %%i in ('dir /b /on /ad %TgtName%*') do set TgtDir=%%i
)

if "%TgtDir%"=="" (
  echo ERROR: not found source directory
  goto END
)
if not exist "%TgtDir%" (
  echo ERROR: not found source directory
  goto END
)

set Arg=%Arg% %HasRtSta% %HasRtDll% %HasRel% %HasDbg% %HasTest%
set Arg=%Arg% LibPrefix:%LibPrefix% LibDir:%SrcLibSubDir%
set Arg=%Arg% LibRel:%CcLibStrRelease% LibDbg:%CcLibStrDebug% LibRtSta:%CcLibStrStatic% LibRtDll:%CcLibStrRtDll%
if "%CcNoRtStatic%"=="1" set Arg=%Arg% rtdll

rem goto BUILD_SKIP
set TgtSrcDir=%TgtDir%\sources
pushd %TgtSrcDir%
if "%HasX86%"=="1" (
  call ..\..\bld_lib_bat\setcc.bat %VcVer% Win32
  call ..\..\bld_lib_bat\bld1_%TgtName%.bat %VcVer% Win32 %Arg%
)
if "%HasX64%"=="1" (
  call ..\..\bld_lib_bat\setcc.bat %VcVer% x64
  call ..\..\bld_lib_bat\bld1_%TgtName%.bat %VcVer% x64 %Arg%
)
popd
:BUILD_SKIP
goto END


:END
popd
endlocal
