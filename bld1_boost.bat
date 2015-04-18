rem @echo off
rem bld1_boost [vc??] [x86/x64] [zlib-?.?.?] [bzip2-?.?.?] [stage:"STAGE-DIR"]
rem ex)
rem cd boost_1_57_0
rem ..\bld_lib_bat\bld1_boost.bat vc12 x64 zlib-1.2.8 bzip2-1.0.6
rem
rem This batch-file license: boost software license version 1.0
setlocal

if not exist b2.exe call bootstrap.bat

set Arch=%CcArch%

set AddrModel=32
set LibRootDir=%~dp0..

:ARG_LOOP
  if "%1"=="" goto ARG_LOOP_EXIT

  if /I "%1"=="vc71"    set CcName=vc71
  if /I "%1"=="vc8"     set CcName=vc8
  if /I "%1"=="vc9"     set CcName=vc9
  if /I "%1"=="vc10"    set CcName=vc10
  if /I "%1"=="vc11"    set CcName=vc11
  if /I "%1"=="vc12"    set CcName=vc12
  if /I "%1"=="vc13"    set CcName=vc13

  if /I "%1"=="x86"     set Arch=x86
  if /I "%1"=="x64"     set Arch=x64

  set ARG=%1
  if /I "%ARG:~0,4%"=="zlib"  set ZlibDir=%1
  if /I "%ARG:~0,5%"=="bzip2" set Bzip2Dir=%1
  if /I "%ARG:~0,6%"=="stage:" set StageDir=%ARG:~6%
  shift
goto ARG_LOOP
:ARG_LOOP_EXIT

if "%CcName%"=="" (
  if /I not "%PATH:Microsoft Visual Studio 13.0=%"=="%PATH%" set CcName=vc13
  if /I not "%PATH:Microsoft Visual Studio 12.0=%"=="%PATH%" set CcName=vc12
  if /I not "%PATH:Microsoft Visual Studio 11.0=%"=="%PATH%" set CcName=vc11
  if /I not "%PATH:Microsoft Visual Studio 10.0=%"=="%PATH%" set CcName=vc10
  if /I not "%PATH:Microsoft Visual Studio 9.0=%"=="%PATH%"  set CcName=vc9
  if /I not "%PATH:Microsoft Visual Studio 8=%"=="%PATH%"    set CcName=vc8
  if /I not "%PATH:Microsoft Visual Studio .NET 2003=%"=="%PATH%" set CcName=vc71
)
if "%Arch%"=="" (
  if /I not "%PATH:Microsoft Visual Studio 13.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 12.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 11.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 10.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 9.0\VC\BIN\amd64=%"=="%PATH%"  set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 8\VC\BIN\amd64=%"=="%PATH%"    set Arch=x64
)

if "%CcName%"=="vc71" set ToolSet=msvc-7.1
if "%CcName%"=="vc8"  set ToolSet=msvc-8.0
if "%CcName%"=="vc9"  set ToolSet=msvc-9.0
if "%CcName%"=="vc10" set ToolSet=msvc-10.0
if "%CcName%"=="vc11" set ToolSet=msvc-11.0
if "%CcName%"=="vc12" set ToolSet=msvc-12.0
if "%CcName%"=="vc13" set ToolSet=msvc-13.0
if "%CcName%"=="vc14" set ToolSet=msvc-14.0

if "%ToolSet%"=="" goto USAGE

if "%Arch%"==""    set Arch=x86
if "%Arch%"=="x86" set AddrModel=32
if "%Arch%"=="x64" set AddrModel=64

set /a ThreadNum=%NUMBER_OF_PROCESSORS%+1

if "%ZlibDir%"==""   set ZlibDir=zlib-1.2.8
if "%Bzip2Dir%"==""  set Bzip2Dir=bzip2-1.0.6
if "%CcArchLib%"=="" set CcArchLib=%StrPrefix%%Arch%

set ZlibDir=%LibRootDir%\%ZlibDir%
set Bzip2Dir=%LibRootDir%\%Bzip2Dir%
if "%StageDir%"=="" set StageDir=stage\%CcArchLib%

set B2Opts=--build-type=complete variant=release,debug address-model=%AddrModel% -j%ThreadNum%
set B2Opts=%B2Opts% --without-python --without-mpi
set B2Opts=%B2Opts% -sNO_COMPRESSION=0 -sNO_ZLIB=0 -sZLIB_SOURCE="%ZlibDir%"
set B2Opts=%B2Opts%                   -sNO_BZIP2=0 -sBZIP2_SOURCE="%Bzip2Dir%"

b2 --toolset=%ToolSet% --stagedir="%StageDir%" %B2Opts%

goto END

:USAGE
echo bld_lib.bat [vc??] [x86/x64] [zlib-?.?.?] [bzip2-?.?.?]

:END
endlocal
