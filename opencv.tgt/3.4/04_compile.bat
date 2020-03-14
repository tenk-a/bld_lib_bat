@rem This batch-file license: boost software license version 1.0
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

set CMAKE_NO_CUDA_OPTS=-DWITH_CUDA=0 -DWITH_CUFFT=0 -DBUILD_CUDA_STUBS=0
set ADD_CMAKE_OPTS=-DWITH_OPENGL=1
set ADD_CMAKE_OPTS=%ADD_CMAKE_OPTS% -DWITH_OPENCL=0 -DWITH_OPENCL_SVM=0 -DWITH_OPENCLAMDFFT=0 -DWITH_OPENCLAMDBLAS=0
set ADD_CMAKE_OPTS=%ADD_CMAKE_OPTS% -DBUILD_PERF_TESTS=0 -DBUILD_TESTS=0 -DBUILD_DOCS=0 -DBUILD_EXAMPLES=0
set ADD_CMAKE_OPTS=%ADD_CMAKE_OPTS% -DINSTALL_CREATE_DISTRIB=ON

rem set ADD_CMAKE_OPTS=%ADD_CMAKE_OPTS% -DPYTHON_DEFAULT_AVAILABLE=OFF

set Platform=%Arch%

if "%VcVer%"=="vc80" goto VC8VC9
if "%VcVer%"=="vc90" goto VC8VC9
goto SKIP_VC8VC9
:VC8VC9
set ADD_CMAKE_OPTS=%ADD_CMAKE_OPTS% -DWITH_OPENCL=0 -DWITH_OPENCL_SVM=0 -DWITH_OPENCLAMDFFT=0 -DWITH_OPENCLAMDBLAS=0
:SKIP_VC8VC9

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

if "%HasRtSta%%HasRtDll%"=="" (
  set HasRtSta=S
  set HasRtDll=L
  rem set HasDll=D
)
if "%HasRel%%HasDbg%"=="" (
  set HasRel=r
  set HasDbg=d
)

if "%EnableCuda%"=="on" goto SKIP_NO_CUDA
set ADD_CMAKE_OPTS=%ADD_CMAKE_OPTS% %CMAKE_NO_CUDA_OPTS%
:SKIP_NO_CUDA

if not "%CcPythonPlatform%"=="%Arch%" (
  set ADD_CMAKE_OPTS=%ADD_CMAKE_OPTS% -DBUILD_opencv_python2=OFF -DBUILD_opencv_python3=OFF
)

if "%HasRtDll%"=="L" call :Bld1 rtdll  %VcVer%_%Arch%_rtdll
if "%HasRtSta%"=="S" call :Bld1 static %VcVer%_%Arch%_static
if "%HasDll%"=="D"   call :Bld1 dll    %VcVer%_%Arch%_dll

endlocal
goto :EOF

:Bld1
set RtType=%1
set Target=%2

set opencv_base=%CD%\source
set contrib_dir=%CD%\opencv_contrib
set BldDir=%CD%\%CcTgtBldDir%\%Target%
if not exist %BldDir% mkdir %BldDir%

pushd %BldDir%

set ADD_CMAKE_OPTS=%ADD_CMAKE_OPTS% OPENCV_EXTRA_MODULES_PATH=%contrib_dir%
rem set ADD_CMAKE_OPTS=%ADD_CMAKE_OPTS% -DOpenCV_INSTALL_BINARIES_PREFIX=../../../install/%Target%/

if exist opencv.sln goto BLD1_SKIP1
if "%RtType%"=="rtdll" goto BLD1_RTDLL
if "%RtType%"=="dll"   goto BLD1_DLL
:BLD1_STATIC
  CMake %PlatformArch% -DBUILD_SHARED_LIBS=0 -DBUILD_WITH_STATIC_CRT=1 %ADD_CMAKE_OPTS% %opencv_base%
  goto BLD1_SKIP1
:BLD1_RTDLL
  CMake %PlatformArch% -DBUILD_SHARED_LIBS=0 -DBUILD_WITH_STATIC_CRT=0 %ADD_CMAKE_OPTS% %opencv_base%
  goto BLD1_SKIP1
:BLD1_DLL
  CMake %PlatformArch% -DBUILD_SHARED_LIBS=1 -DBUILD_WITH_STATIC_CRT=0 %ADD_CMAKE_OPTS% %opencv_base%
:BLD1_SKIP1

rem if "%HasDbg%"=="d" msbuild opencv.sln /t:Rebuild /p:Configuration=debug   /p:Platform=%Platform% /maxcpucount
if "%HasDbg%"=="d" msbuild INSTALL.vcxproj /p:Configuration=debug   /p:Platform=%Platform% /maxcpucount
rem if "%HasRel%"=="r" msbuild opencv.sln /t:Rebuild /p:Configuration=release /p:Platform=%Platform% /maxcpucount
if "%HasRel%"=="r" msbuild INSTALL.vcxproj /t:Rebuild /p:Configuration=release /p:Platform=%Platform% /maxcpucount

popd

exit /b
