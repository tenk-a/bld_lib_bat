@echo off
rem Compile glfw for vc
rem usage: bld1_glfw [win32/x64] [debug/release] [clean]
rem ex)
rem cd glfw-?.?.?
rem ..\bld_lib_bat\bld1_glfw.bat x64
rem
rem This batch-file license: boost software license version 1.0
setlocal

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
set HasTest=
set CleanMode=
set MakeTargetName=
set VcVer=

:ARG_LOOP
  if "%1"=="" goto ARG_LOOP_EXIT

  if /I "%1"=="x86"      set Arch=Win32
  if /I "%1"=="win32"    set Arch=Win32
  if /I "%1"=="x64"      set Arch=x64

  if /I "%1"=="static"   set HasRtSta=S
  if /I "%1"=="rtsta"    set HasRtSta=S
  if /I "%1"=="rtdll"    set HasRtDll=L

  if /I "%1"=="release"  set HasRel=r
  if /I "%1"=="debug"    set HasDbg=d

  if /I "%1"=="clean"    set CleanMode=1

  if /I "%1"=="test"     set HasTest=1

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
  if /I not "%PATH:Microsoft Visual Studio 13.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 12.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 11.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 10.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 9.0\VC\BIN\amd64=%"=="%PATH%"  set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 8\VC\BIN\amd64=%"=="%PATH%"    set Arch=x64
)
if "%Arch%"=="" set Arch=Win32

if "%CcName%"=="vc80" set MakeTargetName=glfw
if "%CcName%"=="vc90" set MakeTargetName=glfw
if "%CcName%"=="vc100" set MakeTargetName=glfw
if "%CcName%"=="vc110" set MakeTargetName=glfw

call :Clean
if "%CleanMode%"=="1" goto :EOF

if "%HasRtSta%%HasRtDll%"=="" (
  set HasRtSta=S
  set HasRtDll=L
)
if "%HasRel%%HasDbg%"=="" (
  set HasRel=r
  set HasDbg=d
)

if "%StrRtSta%%StrRtDll%"=="" set StrRtSta=_static
if "%StrRel%%StrDbg%"==""     set StrDbg=_debug

if "%LibDir%"=="" set LibDir=lib
if not exist %LibDir% mkdir %LibDir%

if "%HasRtSta%%HasRel%"=="Sr" call :Bld1 rtsta release %StrPrefix%%Arch%%StrRtSta%%StrRel%
if "%HasRtSta%%HasDbg%"=="Sd" call :Bld1 rtsta debug   %StrPrefix%%Arch%%StrRtSta%%StrDbg%
if "%HasRtDll%%HasRel%"=="Lr" call :Bld1 rtdll release %StrPrefix%%Arch%%StrRtDll%%StrRel%
if "%HasRtDll%%HasDbg%"=="Ld" call :Bld1 rtdll debug   %StrPrefix%%Arch%%StrRtDll%%StrDbg%

endlocal
goto :EOF


:Bld1
set RtType=%1
set BldType=%2
set Target=%3

set Arg=
if "%RtType%"=="rtdll" (
  set Arg=%Arg% -DUSE_MSVC_RUNTIME_LIBRARY_DLL=ON
) else (
  set Arg=%Arg% -DUSE_MSVC_RUNTIME_LIBRARY_DLL=OFF
)
set Arg=%Arg% -DCMAKE_BUILD_TYPE=%BldType%

CMake -G "NMake Makefiles" %Arg%
if errorlevel 1 goto :EOF
nmake %MakeTargetName%

set DstDir=%LibDir%\%Target%

if not exist %DstDir% mkdir %DstDir%
if exist src\*.lib move src\*.lib %DstDir%\
if exist src\*.dll move src\*.dll %DstDir%\
if exist src\*.pdb move src\*.pdb %DstDir%\

if not "%HasTest%"=="1" goto TEST_SKIP
if not exist %DstDir%\examples mkdir %DstDir%\examples
if exist examples\*.exe move examples\*.exe %DstDir%\examples
if exist examples\*.pdb move examples\*.pdb %DstDir%\examples

if not exist %DstDir%\tests mkdir %DstDir%\tests
if exist tests\*.exe move tests\*.exe %DstDir%\tests
if exist tests\*.pdb move tests\*.pdb %DstDir%\tests
:TEST_SKIP

exit /b


:Clean

call :CleanSub
del glfw3Config.cmake glfw3ConfigVersion.cmake glfw_config.h glfw3.pc

cd src
call :CleanSub
cd ..

cd examples
call :CleanSub
cd ..

cd tests
call :CleanSub
cd ..

exit /b

:CleanSub
if exist Makefile (
  nmake clean
  del Makefile
)
if exist CMakeFiles (
  del /S /F /Q CMakeFiles\*.*
  rmdir /S /Q CMakeFiles
)

del *.ilk *.manifest *.manifest.res *.resource.txt CMakeCache.txt cmake_install.cmake cmake_uninstall.cmake

exit /b
