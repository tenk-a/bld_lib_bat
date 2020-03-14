rem @echo off
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
set CleanMode=

:ARG_LOOP
  set ARG=%1
  if "%1"=="" goto ARG_LOOP_EXIT

  if /I "%1"=="static"   set HasRtSta=S
  if /I "%1"=="static"    set HasRtSta=S
  if /I "%1"=="rtdll"    set HasRtDll=L

  if /I "%1"=="release"  set HasRel=r
  if /I "%1"=="debug"    set HasDbg=d

  if /I "%1"=="clean"    set CleanMode=1

  shift
goto ARG_LOOP
:ARG_LOOP_EXIT

if "%Arch%"=="" set Arch=Win32

if not exist %CcTgtBldDir% mkdir %CcTgtBldDir%


if not "%CleanMode%"=="1" goto SKIP1
  pushd %CcTgtBldDir%
  call :Clean
  popd
  goto :EOF
:SKIP1

if "%HasRtSta%%HasRtDll%"=="" (
  set HasRtSta=S
  set HasRtDll=L
)
if "%HasRel%%HasDbg%"=="" (
  set HasRel=r
  set HasDbg=d
)

rem pushd %CcTgtBldDir%
if "%HasRtSta%%HasRel%"=="Sr" call :Bld1 static release
if "%HasRtSta%%HasDbg%"=="Sd" call :Bld1 static debug
if "%HasRtDll%%HasRel%"=="Lr" call :Bld1 rtdll  release
if "%HasRtDll%%HasDbg%"=="Ld" call :Bld1 rtdll  debug
rem popd

goto END

:Bld1
set Rt=%1
set Conf=%2

set StrLibPath=
call %CcBatDir%\sub\StrLibPath.bat %CcTgtLibPathType% %CcTgtBldDir% %VcVer% %Arch% %Rt% %Conf%
set TgtLibDir=%StrLibPath%
if not exist %TgtLibDir% mkdir %TgtLibDir%

set DstBaseDir=%CD%
pushd %TgtLibDir%

rem call :Clean

set StrLibPath=
call %CcBatDir%\sub\StrLibPath.bat %CcInstallPathType% %CcInstallLibDir% %VcVer% %Arch% %Rt% %Conf%
set LibDir=%StrLibPath%

set ADD_CMAKE_OPTS=
if %Rt%==rtdll (
    set ADD_CMAKE_OPTS=-DWITH_CRT_DLL=true
) else (
    set ADD_CMAKE_OPTS=-DWITH_CRT_DLL=false
)
set ADD_CMAKE_OPTS=%ADD_CMAKE_OPTS% -DZLIB_INCLUDE_DIR=%CcInstallIncDir% -DZLIB_LIBRARY=%LibDir%\zlib.lib
set ADD_CMAKE_OPTS=%ADD_CMAKE_OPTS% -DPNG_PNG_INCLUDE_DIR=%CcInstallIncDir% -DPNG_LIBRARY=%LibDir%\libpng.lib

if not exist Makefile (
  CMake -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=%Conf% %ADD_CMAKE_OPTS% %DstBaseDir%\
  if errorlevel 1 goto BLD1_RET
  if %Rt%==static call :ReplaceMDtoMT
)

nmake
if errorlevel 1 goto BLD1_RET

del *.obj *.exp *.ilk *.res *.resource.txt *.manifest

if not exist %DstBaseDir%\jconfig.h    copy jconfig.h    %DstBaseDir%\
if not exist %DstBaseDir%\jconfigint.h copy jconfigint.h %DstBaseDir%\

set StrLibPath=
call %CcBatDir%\sub\StrLibPath.bat %CcTgtLibPathType% %DstBaseDir%\%CcTgtLibDir% %VcVer% %Arch% %Rt% %Conf%
set TgtLibDir=%StrLibPath%
if not exist %TgtLibDir% mkdir %TgtLibDir%

if exist *.lib move *.lib %TgtLibDir%\
if exist *.dll move *.dll %TgtLibDir%\
if exist turbojpeg.pdb move turbojpeg.pdb %TgtLibDir%\
if exist sharedlib\*.lib move sharedlib\*.lib %TgtLibDir%\
if exist sharedlib\*.dll move sharedlib\*.dll %TgtLibDir%\
if exist sharedlib\jpeg.pdb move sharedlib\jpeg.pdb %TgtLibDir%\

goto EXE_SKIP
set StrLibPath=
call %CcBatDir%\sub\StrLibPath.bat %CcTgtLibPathType% %DstBaseDir%\exe %VcVer% %Arch% %Rt% %Conf%
set DstExeDir=%StrLibPath%
if not exist %DstExeDir% mkdir %DstExeDir%
if exist *.exe move *.exe %DstExeDir%\
if exist *.pdb move *.pdb %DstExeDir%\
if exist sharedlib\*.exe move sharedlib\*.exe %DstExeDir%\
if exist sharedlib\*.pdb move sharedlib\*.pdb %DstExeDir%\
:EXE_SKIP

:BLD1_RET
popd
exit /b


:Clean
del /S /F /Q .\*.*
exit /b


:ReplaceMTtoMD
for /R %%i in (CMakeCache.txt) do (
  if exist %%i call :Rep1MTtoMD %%i
)
exit /b
:Rep1MTtoMD
..\bld_lib_bat\tiny_replstr.exe -x ++ "/MT" "/MD" -- %1
exit /b

:ReplaceMDtoMT
for /R %%i in (CMakeCache.txt) do (
  if exist %%i call :Rep1MDtoMT %%i
)
exit /b

:Rep1MDtoMT
..\bld_lib_bat\tiny_replstr.exe -x ++ "/MD" "/MT" -- %1
exit /b

:END
endlocal
