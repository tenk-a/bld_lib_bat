echo on
rem @echo off
rem Compile libcv for vc
rem This batch-file license: boost software license version 1.0
setlocal

set CMAKE_NO_CUDA_OPTS=-DWITH_CUDA=0 -DWITH_CUFFT=0 -DBUILD_CUDA_STUBS=0
set ADD_CMAKE_OPTS=-DWITH_OPENGL=1
set ADD_CMAKE_OPTS=%ADD_CMAKE_OPTS% -DWITH_OPENCL=0 -DWITH_OPENCL_SVM=0 -DWITH_OPENCLAMDFFT=0 -DWITH_OPENCLAMDBLAS=0
set ADD_CMAKE_OPTS=%ADD_CMAKE_OPTS% -DBUILD_PERF_TESTS=0 -DBUILD_TESTS=0 -DBUILD_DOCS=0 -DBUILD_EXAMPLES=0
set ADD_CMAKE_OPTS=%ADD_CMAKE_OPTS% -DINSTALL_CREATE_DISTRIB=ON

rem set ADD_CMAKE_OPTS=%ADD_CMAKE_OPTS% -DPYTHON_DEFAULT_AVAILABLE=OFF


set Arch=
set LibDir=
set StrPrefix=
set StrRel=_release
set StrDbg=_debug
set StrRtSta=_static
set StrRtDll=
set StrDll=_dll

set HasRel=
set HasDbg=
set HasRtSta=
set HasRtDll=
set HasDll=
set VcVer=
set EnableCuda=

:ARG_LOOP
  if "%1"=="" goto ARG_LOOP_EXIT

  if /I "%1"=="x86"      set Arch=Win32
  if /I "%1"=="Win32"    set Arch=Win32
  if /I "%1"=="x64"      set Arch=x64

  if /I "%1"=="static"   set HasRtSta=S
  if /I "%1"=="rtsta"    set HasRtSta=S
  if /I "%1"=="rtdll"    set HasRtDll=L
  if /I "%1"=="dll"      set HasDll=L

  if /I "%1"=="release"  set HasRel=r
  if /I "%1"=="debug"    set HasDbg=d

  if /I "%1"=="EnableCuda" set EnableCuda=on

  if /I "%1"=="vc71"     set VcVer=vc71
  if /I "%1"=="vc80"     set VcVer=vc80
  if /I "%1"=="vc90"     set VcVer=vc90
  if /I "%1"=="vc100"    set VcVer=vc100
  if /I "%1"=="vc110"    set VcVer=vc110
  if /I "%1"=="vc120"    set VcVer=vc120
  if /I "%1"=="vc130"    set VcVer=vc130
  if /I "%1"=="vc140"    set VcVer=vc140
  if /I "%1"=="vc141"    set VcVer=vc141

  set ARG=%1
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

if "%VcVer%"=="" (
  if /I not "%PATH:Microsoft Visual Studio .NET 2003=%"=="%PATH%" set VcVer=vc71
  if /I not "%PATH:Microsoft Visual Studio 8=%"=="%PATH%"    set VcVer=vc80
  if /I not "%PATH:Microsoft Visual Studio 9.0=%"=="%PATH%"  set VcVer=vc90
  if /I not "%PATH:Microsoft Visual Studio 10.0=%"=="%PATH%" set VcVer=vc100
  if /I not "%PATH:Microsoft Visual Studio 11.0=%"=="%PATH%" set VcVer=vc110
  if /I not "%PATH:Microsoft Visual Studio 12.0=%"=="%PATH%" set VcVer=vc120
  if /I not "%PATH:Microsoft Visual Studio 13.0=%"=="%PATH%" set VcVer=vc130
  if /I not "%PATH:Microsoft Visual Studio 14.0=%"=="%PATH%" set VcVer=vc140
  if /I not "%PATH:Microsoft Visual Studio\2017=%"=="%PATH%" set VcVer=vc141
)

if "%StrPrefix%"=="" (
  if not "%VcVer%"=="" (
    if "%StrPrefix%"=="" set StrPrefix=%VcVer%_
  )
)

if "%Arch%"=="" (
  if "%VcVer%"=="vc141"    if /I not "%PATH:\bin\HostX64\x64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 14.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 12.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 11.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 10.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 9.0\VC\BIN\amd64=%"=="%PATH%"  set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 8\VC\BIN\amd64=%"=="%PATH%"    set Arch=x64
)
if "%Arch%"=="" set Arch=Win32
set Platform=%Arch%
if "%Platform%"=="x86" set Platform=Win32

if "%VcVer%"=="vc80" goto VC8VC9
if "%VcVer%"=="vc90" goto VC8VC9
goto SKIP_VC8VC9
:VC8VC9
set ADD_CMAKE_OPTS=%ADD_CMAKE_OPTS% -DWITH_OPENCL=0 -DWITH_OPENCL_SVM=0 -DWITH_OPENCLAMDFFT=0 -DWITH_OPENCLAMDBLAS=0
:SKIP_VC8VC9

set Generator=
if "%VcVer%"=="vc141" set "Generator=Visual Studio 15 2017"
if "%VcVer%"=="vc140" set "Generator=Visual Studio 14 2015"
if "%VcVer%"=="vc120" set "Generator=Visual Studio 12 2013"
if "%VcVer%"=="vc110" set "Generator=Visual Studio 11 2012"
if "%VcVer%"=="vc100" set "Generator=Visual Studio 10 2010"
if "%VcVer%"=="vc90"  set "Generator=Visual Studio 9 2008"
if "%VcVer%"=="vc80"  set "Generator=Visual Studio 8 2005"

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

if "%LibDir%"=="" set LibDir=lib
if not exist %LibDir% mkdir %LibDir%

if not exist build    mkdir build

if "%EnableCuda%"=="on" goto SKIP_NO_CUDA
set ADD_CMAKE_OPTS=%ADD_CMAKE_OPTS% %CMAKE_NO_CUDA_OPTS%
:SKIP_NO_CUDA

if not "%CcPythonPlatform%"=="%Arch%" (
  set ADD_CMAKE_OPTS=%ADD_CMAKE_OPTS% -DBUILD_opencv_python2=OFF -DBUILD_opencv_python3=OFF
)

if "%HasRtDll%"=="L" call :Bld1 rtdll  %StrPrefix%%Arch%%StrRtDll%
if "%HasRtSta%"=="S" call :Bld1 static %StrPrefix%%Arch%%StrRtSta%
if "%HasDll%"=="D"   call :Bld1 dll    %StrPrefix%%Arch%%StrDll%

endlocal
goto :EOF


:Bld1
set RtType=%1
set Target=%2

rem set opencv_base=..\..
rem set BldDir=build\%Target%
set BldDir=..\build\%Target%
if not exist %BldDir% mkdir %BldDir%

pushd %BldDir%
set opencv_base=..\..\sources
set contrib_dir=..\..\opencv_contrib

set ADD_CMAKE_OPTS=%ADD_CMAKE_OPTS% OPENCV_EXTRA_MODULES_PATH=%contrib_dir%
rem set ADD_CMAKE_OPTS=%ADD_CMAKE_OPTS% -DOpenCV_INSTALL_BINARIES_PREFIX=../../../install/%Target%/

if exist opencv.sln goto BLD1_SKIP1
if "%RtType%"=="rtdll" goto BLD1_RTDLL
if "%RtType%"=="dll"   goto BLD1_DLL
:BLD1_STATIC
  CMake -G "%Generator%" -DBUILD_SHARED_LIBS=0 -DBUILD_WITH_STATIC_CRT=1 %ADD_CMAKE_OPTS% %opencv_base%
  goto BLD1_SKIP1
:BLD1_RTDLL
  CMake -G "%Generator%" -DBUILD_SHARED_LIBS=0 -DBUILD_WITH_STATIC_CRT=0 %ADD_CMAKE_OPTS% %opencv_base%
  goto BLD1_SKIP1
:BLD1_DLL
  CMake -G "%Generator%" -DBUILD_SHARED_LIBS=1 -DBUILD_WITH_STATIC_CRT=0 %ADD_CMAKE_OPTS% %opencv_base%
:BLD1_SKIP1

rem if "%HasDbg%"=="d" msbuild opencv.sln /t:Rebuild /p:Configuration=debug   /p:Platform=%Platform% /maxcpucount
if "%HasDbg%"=="d" msbuild INSTALL.vcxproj /p:Configuration=debug   /p:Platform=%Platform% /maxcpucount
rem if "%HasRel%"=="r" msbuild opencv.sln /t:Rebuild /p:Configuration=release /p:Platform=%Platform% /maxcpucount
if "%HasRel%"=="r" msbuild INSTALL.vcxproj /t:Rebuild /p:Configuration=release /p:Platform=%Platform% /maxcpucount



popd

exit /b
