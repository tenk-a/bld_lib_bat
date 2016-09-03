echo on
rem @echo off
rem Compile libcv for vc
rem This batch-file license: boost software license version 1.0
setlocal

set CMAKE_NO_CUDA_OPTS=-DWITH_CUDA=0 -DWITH_CUFFT=0 -DBUILD_CUDA_STUBS=0
set ADD_CMAKE_OPTS=-DWITH_OPENGL=1
set ADD_CMAKE_OPTS=%ADD_CMAKE_OPTS% -DWITH_OPENCL=0 -DWITH_OPENCL_SVM=0 -DWITH_OPENCLAMDFFT=0 -DWITH_OPENCLAMDBLAS=0
rem set ADD_CMAKE_OPTS=%ADD_CMAKE_OPTS% -DBUILD_PERF_TESTS=0 -DBUILD_TESTS=0
rem set ADD_CMAKE_OPTS=%ADD_CMAKE_OPTS% -DBUILD_EXAMPLES=1

set Arch=%CcArch%
set LibDir=%CcLibDir%
rem set LibCopyDir=
set StrPrefix=%CcLibPrefix%
set StrRtSta=%CcLibStrRtStatic%
set StrRtDll=%CcLibStrRtDll%
set StrDll=%CcLibStrDll%
set StrRel=%CcLibStrRelease%
set StrDbg=%CcLibStrDebug%

set HasRtSta=
set HasRtDll=
set HasDll=
set Compiler=
set EnableCuda=

set LibArchX86=%CcLibArchX86%
if "%LibArchX86%"=="" set LibArchX86=Win32

:ARG_LOOP
  if "%1"=="" goto ARG_LOOP_EXIT

  if /I "%1"=="vc71"      set Compiler=vc71
  if /I "%1"=="vc80"      set Compiler=vc80
  if /I "%1"=="vc90"      set Compiler=vc90
  if /I "%1"=="vc100"     set Compiler=vc100
  if /I "%1"=="vc110"     set Compiler=vc110
  if /I "%1"=="vc120"     set Compiler=vc120
  if /I "%1"=="vc130"     set Compiler=vc130
  if /I "%1"=="vc140"     set Compiler=vc140

  if /I "%1"=="x86"      set Arch=%LibArchX86%
  if /I "%1"=="win32"    set Arch=%LibArchX86%
  if /I "%1"=="x64"      set Arch=x64

  if /I "%1"=="static"   set HasRtSta=S
  if /I "%1"=="rtsta"    set HasRtSta=S
  if /I "%1"=="rtdll"    set HasRtDll=L
  if /I "%1"=="dll"      set HasDll=L

  if /I "%1"=="EnableCuda" set EnableCuda=on

  set ARG=%1
  rem if /I "%ARG:~0,8%"=="LibCopy:"    set LibCopyDir=%ARG:~8%
  if /I "%ARG:~0,7%"=="LibDir:"     set LibDir=%ARG:~7%
  if /I "%ARG:~0,10%"=="LibPrefix:" set StrPrefix=%ARG:~10%
  if /I "%ARG:~0,9%"=="LibRtSta:"   set StrRtSta=%ARG:~9%
  if /I "%ARG:~0,9%"=="LibRtDll:"   set StrRtDll=%ARG:~9%
  if /I "%ARG:~0,7%"=="LibDll:"     set StrDll=%ARG:~7%
  if /I "%ARG:~0,7%"=="LibRel:"     set StrRel=%ARG:~7%
  if /I "%ARG:~0,7%"=="LibDbg:"     set StrDbg=%ARG:~7%

  shift
goto ARG_LOOP
:ARG_LOOP_EXIT

if "%Compiler%"=="" (
  rem if /I not "%PATH:Microsoft Visual Studio 13.0=%"=="%PATH%" set Compiler=vc13
  if /I not "%PATH:Microsoft Visual Studio 14.0=%"=="%PATH%" set Compiler=vc140
  if /I not "%PATH:Microsoft Visual Studio 12.0=%"=="%PATH%" set Compiler=vc120
  if /I not "%PATH:Microsoft Visual Studio 11.0=%"=="%PATH%" set Compiler=vc110
  if /I not "%PATH:Microsoft Visual Studio 10.0=%"=="%PATH%" set Compiler=vc100
  if /I not "%PATH:Microsoft Visual Studio 9.0=%"=="%PATH%"  set Compiler=vc90
  if /I not "%PATH:Microsoft Visual Studio 8=%"=="%PATH%"    set Compiler=vc80
)
if "%Compiler%"=="" (
  echo unkown compiler
  goto END
)

if "%Arch%"=="" (
  rem if /I not "%PATH:Microsoft Visual Studio 13.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 14.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 12.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 11.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 10.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 9.0\VC\BIN\amd64=%"=="%PATH%"  set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 8\VC\BIN\amd64=%"=="%PATH%"    set Arch=x64
)
if "%Arch%"=="" set Arch=%LibArchX86%
set Platform=%Arch%
if "%Platform%"=="x86" set Platform=Win32

if "%Compiler%"=="vc80" goto VC8VC9
if "%Compiler%"=="vc90" goto VC8VC9
goto SKIP_VC8VC9
:VC8VC9
set ADD_CMAKE_OPTS=%ADD_CMAKE_OPTS% -DWITH_OPENCL=0 -DWITH_OPENCL_SVM=0 -DWITH_OPENCLAMDFFT=0 -DWITH_OPENCLAMDBLAS=0
:SKIP_VC8VC9

set Generator=
rem if "%Compiler%"=="vs13" set SlnDir=VS2014
if "%Compiler%"=="vc140" set "Generator=Visual Studio 14 2015"
if "%Compiler%"=="vc120" set "Generator=Visual Studio 12 2013"
if "%Compiler%"=="vc110" set "Generator=Visual Studio 11 2012"
if "%Compiler%"=="vc100" set "Generator=Visual Studio 10 2010"
if "%Compiler%"=="vc90"  set "Generator=Visual Studio 9 2008"
if "%Compiler%"=="vc80"  set "Generator=Visual Studio 8 2005"

if "%Arch%"=="x64" set "Generator=%Generator% Win64"


if "%HasRtSta%%HasRtDll%"=="" (
  set HasRtSta=S
  set HasRtDll=L
  rem set HasDll=D
)
if "%HasRel%%HasDbg%"=="" (
  set HasRel=r
  set HasDbg=d
)

if "%StrRel%%StrDbg%"==""     set StrDbg=_debug
if "%StrRtSta%%StrRtDll%"=="" set StrRtSta=_static

if not exist %LibDir% mkdir %LibDir%
if not exist build    mkdir build

if "%EnableCuda%"=="on" goto SKIP_NO_CUDA
set ADD_CMAKE_OPTS=%ADD_CMAKE_OPTS% %CMAKE_NO_CUDA_OPTS%
:SKIP_NO_CUDA

if "%HasRtDll%"=="L" call :Bld1 rtdll  %StrPrefix%%Arch%%StrRtDll%
if "%HasRtSta%"=="S" call :Bld1 static %StrPrefix%%Arch%%StrRtSta%
if "%HasDll%"=="D"   call :Bld1 dll    %StrPrefix%%Arch%%StrDll%


endlocal
goto :EOF


:Bld1
set RtType=%1
set Target=%2

set BldDir=build\%Target%
if not exist %BldDir% mkdir %BldDir%

pushd %BldDir%

if "%RtType%"=="rtdll" goto BLD1_RTDLL
if "%RtType%"=="dll"   goto BLD1_DLL
:BLD1_STATIC
  CMake -G "%Generator%" -DBUILD_SHARED_LIBS=0 -DBUILD_WITH_STATIC_CRT=1 %ADD_CMAKE_OPTS% ..\..
  goto BLD1_SKIP1
:BLD1_RTDLL
  CMake -G "%Generator%" -DBUILD_SHARED_LIBS=0 -DBUILD_WITH_STATIC_CRT=0 %ADD_CMAKE_OPTS% ..\..
  goto BLD1_SKIP1
:BLD1_DLL
  CMake -G "%Generator%" -DBUILD_SHARED_LIBS=1 -DBUILD_WITH_STATIC_CRT=0 %ADD_CMAKE_OPTS% ..\..
:BLD1_SKIP1

msbuild opencv.sln  /t:Rebuild /p:Configuration=debug   /p:Platform=%Platform%
msbuild opencv.sln  /t:Rebuild /p:Configuration=release /p:Platform=%Platform%

popd

set TgtDir=%LibDir%\%Target%
if not exist %TgtDir%%StrDbg% mkdir %TgtDir%%StrDbg%
if not exist %TgtDir%%StrRel% mkdir %TgtDir%%StrRel%

copy %BldDir%\lib\debug\*.*   %TgtDir%%StrDbg%\
copy %BldDir%\lib\release\*.* %TgtDir%%StrRel%\

exit /b
