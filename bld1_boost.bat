@echo off
rem bld1_boost [vc??] [win32/x64] [zlib-?.?.?] [bzip2-?.?.?] [stage:"STAGE-DIR"] [LibPrefix:PREFIX]
rem ex)
rem cd boost_1_57_0
rem ..\bld_lib_bat\bld1_boost.bat vc120 x64 zlib-1.2.8 bzip2-1.0.6
rem
rem This batch-file license: boost software license version 1.0
setlocal

if not exist b2.exe call bootstrap.bat

set Arch=%CcArch%

set AddrModel=32
set LibRootDir=%~dp0..
set ZlibDir=
set Bzip2Dir=
set StageDir=
set StrPrefix=
set Compiler=

set LibArchX86=%CcLibArchX86%
if "%LibArchX86%"=="" set LibArchX86=Win32

:ARG_LOOP
  if "%1"=="" goto ARG_LOOP_EXIT

  if /I "%1"=="vc71"    set Compiler=vc71
  if /I "%1"=="vc80"    set Compiler=vc80
  if /I "%1"=="vc90"    set Compiler=vc90
  if /I "%1"=="vc100"   set Compiler=vc100
  if /I "%1"=="vc110"   set Compiler=vc110
  if /I "%1"=="vc120"   set Compiler=vc120
  if /I "%1"=="vc130"   set Compiler=vc130
  if /I "%1"=="vc140"   set Compiler=vc140

  if /I "%1"=="x86"     set Arch=%LibArchX86%
  if /I "%1"=="win32"   set Arch=%LibArchX86%
  if /I "%1"=="x64"     set Arch=x64

  set ARG=%1
  if /I "%ARG:~0,5%"=="zlib:"  set ZlibDir=%ARG:~5%
  if /I "%ARG:~0,6%"=="bzip2:" set Bzip2Dir=%ARG:~6%
  if /I "%ARG:~0,6%"=="stage:" set StageDir=%ARG:~6%
  if /I "%ARG:~0,10%"=="LibPrefix:" set StrPrefix=%ARG:~10%

  shift
goto ARG_LOOP
:ARG_LOOP_EXIT

if "%Compiler%"=="" (
  if /I not "%PATH:Microsoft Visual Studio 14.0=%"=="%PATH%" set Compiler=vc140
  if /I not "%PATH:Microsoft Visual Studio 13.0=%"=="%PATH%" set Compiler=vc130
  if /I not "%PATH:Microsoft Visual Studio 12.0=%"=="%PATH%" set Compiler=vc120
  if /I not "%PATH:Microsoft Visual Studio 11.0=%"=="%PATH%" set Compiler=vc110
  if /I not "%PATH:Microsoft Visual Studio 10.0=%"=="%PATH%" set Compiler=vc100
  if /I not "%PATH:Microsoft Visual Studio 9.0=%"=="%PATH%"  set Compiler=vc90
  if /I not "%PATH:Microsoft Visual Studio 8=%"=="%PATH%"    set Compiler=vc80
  if /I not "%PATH:Microsoft Visual Studio .NET 2003=%"=="%PATH%" set Compiler=vc71
)
if "%Arch%"=="" (
  if /I not "%PATH:Microsoft Visual Studio 14.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 13.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 12.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 11.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 10.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 9.0\VC\BIN\amd64=%"=="%PATH%"  set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 8\VC\BIN\amd64=%"=="%PATH%"    set Arch=x64
)

if "%Compiler%"=="vc71"  set ToolSet=msvc-7.1
if "%Compiler%"=="vc80"  set ToolSet=msvc-8.0
if "%Compiler%"=="vc90"  set ToolSet=msvc-9.0
if "%Compiler%"=="vc100" set ToolSet=msvc-10.0
if "%Compiler%"=="vc110" set ToolSet=msvc-11.0
if "%Compiler%"=="vc120" set ToolSet=msvc-12.0
if "%Compiler%"=="vc130" set ToolSet=msvc-13.0
if "%Compiler%"=="vc140" set ToolSet=msvc-14.0

if "%ToolSet%"=="" goto USAGE

if "%Arch%"==""    set Arch=%LibArchX86%
if "%Arch%"=="%LibArchX86%" set AddrModel=32
if "%Arch%"=="x64" set AddrModel=64

set /a ThreadNum=%NUMBER_OF_PROCESSORS%+1

if "%ZlibDir%"=="" (
  for /f %%i in ('dir /b /on /ad %LibRootDir%\zlib*') do set ZlibDir=%LibRootDir%\%%i
)
if "%Bzip2Dir%"=="" (
  for /f %%i in ('dir /b /on /ad %LibRootDir%\bzip2*') do set Bzip2Dir=%LibRootDir%\%%i
)
set CompreOpts=
if not "%ZlibDir%"=="" set CompreOpts=%CompreOpts% -sNO_ZLIB=0 -sZLIB_SOURCE="%ZlibDir%"
if not "%Bzip2Dir%"=="" set CompreOpts=%CompreOpts% -sNO_BZIP2=0 -sBZIP2_SOURCE="%Bzip2Dir%"
if not "%CompreOpts%"=="" set CompreOpts=-sNO_COMPRESSION=0 %CompreOpts%

if "%StageDir%"=="" set StageDir=stage\%StrPrefix%%Arch%

set B2Opts=--build-type=complete variant=release,debug address-model=%AddrModel% -j%ThreadNum%
set B2Opts=%B2Opts% --without-python --without-mpi %CompreOpts%

b2 --toolset=%ToolSet% --stagedir="%StageDir%" %B2Opts%

goto END

:USAGE
echo bld_lib.bat [vc??] [win32/x64] [zlib:ZLIB_SRC_DIR] [bzip2:BZIP2_SRC_DIR]

:END
endlocal
