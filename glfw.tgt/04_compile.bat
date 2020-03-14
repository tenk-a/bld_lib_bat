@echo off
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

set CleanMode=
set MakeTargetName=

:ARG_LOOP
  set ARG=%1

  if "%ARG%"=="" goto ARG_LOOP_EXIT
  if /I "%ARG%"=="static"   set HasRtSta=S
  if /I "%ARG%"=="rtdll"    set HasRtDll=L
  if /I "%ARG%"=="release"  set HasRel=r
  if /I "%ARG%"=="debug"    set HasDbg=d
  if /I "%ARG%"=="test"     set HasTest=1

  if /I "%ARG%"=="clean"    set CleanMode=1

  shift
goto ARG_LOOP
:ARG_LOOP_EXIT

if "%VcVer%"=="vc80"  set MakeTargetName=glfw
if "%VcVer%"=="vc90"  set MakeTargetName=glfw
if "%VcVer%"=="vc100" set MakeTargetName=glfw
if "%VcVer%"=="vc110" set MakeTargetName=glfw

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

if "%HasRtSta%%HasRel%"=="Sr" call :Bld1 release static
if "%HasRtSta%%HasDbg%"=="Sd" call :Bld1 debug   static
if "%HasRtDll%%HasRel%"=="Lr" call :Bld1 release rtdll
if "%HasRtDll%%HasDbg%"=="Ld" call :Bld1 debug   rtdll

goto END


:Bld1
set Rt=%1
set Conf=%2

set Arg=
if "%Rt%"=="rtdll" (
  set Arg=%Arg% -DUSE_MSVC_RUNTIME_LIBRARY_DLL=ON
) else (
  set Arg=%Arg% -DUSE_MSVC_RUNTIME_LIBRARY_DLL=OFF
)
set Arg=%Arg% -DCMAKE_BUILD_TYPE=%Conf%

CMake -G "NMake Makefiles" %Arg%
if errorlevel 1 goto :EOF
nmake %MakeTargetName%
echo on

set StrLibPath=
call %CcBatDir%\sub\StrLibPath.bat %CcTgtLibPathType% %CcTgtLibDir% %VcVer% %Arch% %Rt% %Conf%
set TgtLibDir=%StrLibPath%
if not exist %TgtLibDir% mkdir %TgtLibDir%

if exist src\*.lib move src\*.lib %TgtLibDir%\
if exist src\*.dll move src\*.dll %TgtLibDir%\
if exist src\*.pdb move src\*.pdb %TgtLibDir%\

if not "%HasTest%"=="1" goto TEST_SKIP
if not exist %TgtLibDir%\examples mkdir %TgtLibDir%\examples
if exist examples\*.exe move examples\*.exe %TgtLibDir%\examples
if exist examples\*.pdb move examples\*.pdb %TgtLibDir%\examples

if not exist %TgtLibDir%\tests mkdir %TgtLibDir%\tests
if exist tests\*.exe move tests\*.exe %TgtLibDir%\tests
if exist tests\*.pdb move tests\*.pdb %TgtLibDir%\tests
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

:END
endlocal
exit /b
