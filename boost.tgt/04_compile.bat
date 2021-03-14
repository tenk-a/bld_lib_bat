rem This batch-file license: boost software license version 1.0
setlocal

set VcVer=%1
shift
set Arch=%1
shift

if not exist b2.exe call bootstrap.bat

set LibDir=%CcTgtLibDir%

:ARG_LOOP
  set ARG=%1

  if "%ARG%"=="" goto ARG_LOOP_EXIT
  if /I "%ARG%"=="static"   set HasRtSta=S
  if /I "%ARG%"=="rtdll"    set HasRtDll=L
  if /I "%ARG%"=="dll"      set HasDll=D
  if /I "%ARG%"=="release"  set HasRel=r
  if /I "%ARG%"=="debug"    set HasDbg=d
  if /I "%ARG%"=="test"     set HasTest=1

  if /I "%ARG:~0,7%"=="LibDir:"     set LibDir=%ARG:~7%

  shift
goto ARG_LOOP
:ARG_LOOP_EXIT

if "%VcVer%"=="vc71"  set ToolSet=msvc-7.1
if "%VcVer%"=="vc80"  set ToolSet=msvc-8.0
if "%VcVer%"=="vc90"  set ToolSet=msvc-9.0
if "%VcVer%"=="vc100" set ToolSet=msvc-10.0
if "%VcVer%"=="vc110" set ToolSet=msvc-11.0
if "%VcVer%"=="vc120" set ToolSet=msvc-12.0
if "%VcVer%"=="vc130" set ToolSet=msvc-13.0
if "%VcVer%"=="vc140" set ToolSet=msvc-14.0
if "%VcVer%"=="vc141" set ToolSet=msvc-14.1
if "%VcVer%"=="vc142" set ToolSet=msvc-14.2
if "%VcVer%"=="clang" set ToolSet=clang
if "%VcVer%"=="gcc"   set ToolSet=gcc
if "%VcVer%"=="g++"   set ToolSet=gcc

if "%ToolSet%"=="" (
 echo Bad %%VcVer%%
 exit /b 1
)

set AddrModel=32
if "%Arch%"==""      set Arch=Win32
if "%Arch%"=="Win32" set AddrModel=32
if "%Arch%"=="x64"   set AddrModel=64

set /a ThreadNum=%NUMBER_OF_PROCESSORS%+1

set CompreOpts=
if not "%CcZlibDir%"==""  set CompreOpts=%CompreOpts% -sNO_ZLIB=0 -sZLIB_SOURCE="%CcZlibDir%"
if not "%CcBzip2Dir%"=="" set CompreOpts=%CompreOpts% -sNO_BZIP2=0 -sBZIP2_SOURCE="%CcBzip2Dir%"
if not "%CompreOpts%"=="" set CompreOpts=-sNO_COMPRESSION=0 %CompreOpts%

set StageDir=
if /I "%CcTgtLibPathType%"=="D_VA"  set StageDir=%LibDir%\%VcVer%\%Arch%
if /I "%CcTgtLibPathType%"=="D_AV"  set StageDir=%LibDir%\%Arch%\%VcVer%
if /I "%CcTgtLibPathType%"=="J_VA"  set StageDir=%LibDir%\%VcVer%_%Arch%
if /I "%CcTgtLibPathType%"=="J_AV"  set StageDir=%LibDir%\%Arch%_%VcVer%
if "%StageDir%"=="" (
  set Set %%CcTgtLibPathType%%=D_AV,D_VA,J_AV or J_VA
  endlocal
  exit /b 1
)

set B2Opts=--build-type=complete variant=release,debug address-model=%AddrModel% -j%ThreadNum%
set B2Opts=%B2Opts% --without-python --without-mpi %CompreOpts%

if "%HasRel%%HasDbg%"=="r" set B2Opts=%B2Opts% variant=release
if "%HasRel%%HasDbg%"=="d" set B2Opts=%B2Opts% variant=debug
if "%HasRtSta%%HasRtDll%"=="S" set B2Opts=%B2Opts% runtime-link=static
if "%HasRtSta%%HasRtDll%"=="L" set B2Opts=%B2Opts% runtime-link=shared
if "%HasRtSta%%HasRtDll%%HasDll%"=="D" set B2Opts=%B2Opts% runtime-link=shared link=shared
if "%HasRel%%HasDbg%"=="d" set B2Opts=%B2Opts% variant=debug

b2 --toolset=%ToolSet% --stagedir="%StageDir%" %B2Opts%

endlocal
