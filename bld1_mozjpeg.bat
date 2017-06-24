@echo off
rem Compile mozjpeg for vc
rem usage: bld1_mozjpeg [win32/x64] [debug/release] [clean]
rem ex)
rem cd mozjpeg
rem ..\bld_lib_bat\bld1_mozjpeg.bat x64
rem
rem This batch-file license: boost software license version 1.0
setlocal

set Arch=%CcArch%
set LibDir=%CcLibDir%
set LibCopyDir=
set StrPrefix=%CcLibPrefix%
set StrRtSta=%CcLibStrStatic%
set StrRtDll=%CcLibStrRtDll%
set StrRel=%CcLibStrRelease%
set StrDbg=%CcLibStrDebug%

set HasRel=
set HasDbg=
set HasRtSta=
set HasRtDll=
set CleanMode=

set LibArchX86=%CcLibArchX86%
if "%LibArchX86%"=="" set LibArchX86=Win32

:ARG_LOOP
  if "%1"=="" goto ARG_LOOP_EXIT

  if /I "%1"=="x86"      set Arch=%LibArchX86%
  if /I "%1"=="win32"    set Arch=%LibArchX86%
  if /I "%1"=="x64"      set Arch=x64

  if /I "%1"=="static"   set HasRtSta=S
  if /I "%1"=="rtsta"    set HasRtSta=S
  if /I "%1"=="rtdll"    set HasRtDll=L

  if /I "%1"=="release"  set HasRel=r
  if /I "%1"=="debug"    set HasDbg=d

  if /I "%1"=="clean"    set CleanMode=1

  set ARG=%1
  if /I "%ARG:~0,8%"=="LibCopy:"    set LibCopyDir=%ARG:~8%
  if /I "%ARG:~0,7%"=="LibDir:"     set LibDir=%ARG:~7%
  if /I "%ARG:~0,10%"=="LibPrefix:" set StrPrefix=%ARG:~10%
  if /I "%ARG:~0,9%"=="LibRtSta:"   set StrRtSta=%ARG:~9%
  if /I "%ARG:~0,9%"=="LibRtDll:"   set StrRtDll=%ARG:~9%
  if /I "%ARG:~0,7%"=="LibRel:"     set StrRel=%ARG:~7%
  if /I "%ARG:~0,7%"=="LibDbg:"     set StrDbg=%ARG:~7%

  shift
goto ARG_LOOP
:ARG_LOOP_EXIT

if "%Arch%"=="" (
  if /I not "%PATH:Microsoft Visual Studio 14.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 13.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 12.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 11.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 10.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 9.0\VC\BIN\amd64=%"=="%PATH%"  set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 8\VC\BIN\amd64=%"=="%PATH%"    set Arch=x64
)
if "%Arch%"=="" set Arch=%LibArchX86%

if "%LibDir%"==".\lib" set LibDir=
if "%LibDir%"=="lib" set LibDir=

if not exist bld mkdir bld
cd bld

if "%CleanMode%"=="1" (
  call :Clean
  cd ..
  goto :EOF
)


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


if "%HasRtSta%%HasRel%"=="Sr" call :Bld1 rtsta release %StrPrefix%%Arch%%StrRtSta%%StrRel%
if "%HasRtSta%%HasDbg%"=="Sd" call :Bld1 rtsta debug   %StrPrefix%%Arch%%StrRtSta%%StrDbg%
if "%HasRtDll%%HasRel%"=="Lr" call :Bld1 rtdll release %StrPrefix%%Arch%%StrRtDll%%StrRel%
if "%HasRtDll%%HasDbg%"=="Ld" call :Bld1 rtdll debug   %StrPrefix%%Arch%%StrRtDll%%StrDbg%

cd ..
endlocal
goto :EOF


:Bld1
set RtType=%1
set BldType=%2
set Target=%3

if not exist %Target% mkdir %Target%
pushd %Target%

call :Clean

set ADD_CMAKE_OPTS=
if %RtType%==rtdll (
    set ADD_CMAKE_OPTS=-DWITH_CRT_DLL=true
) else (
    set ADD_CMAKE_OPTS=-DWITH_CRT_DLL=false
)
CMake -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=%BldType% %ADD_CMAKE_OPTS% ..\..\
if errorlevel 1 goto :EOF

rem if %RtType%==rtdll (
rem   call :ReplaceMTtoMD
rem )
if %RtType%==rtsta (
    call :ReplaceMDtoMT
)

nmake
if errorlevel 1 goto :EOF

if "%LibDir%"=="" set LibDir=..\..\lib
if not exist %LibDir% mkdir %LibDir%

set DstDir=%LibDir%\%Target%
if not exist %DstDir% mkdir %DstDir%
if not exist %DstDir%\exe mkdir %DstDir%\exe

del *.obj *.exp *.ilk *.res *.resource.txt *.manifest

if exist *.lib move *.lib %DstDir%\
if exist *.dll move *.dll %DstDir%\
if exist turbojpeg.pdb move turbojpeg.pdb %DstDir%\
if exist sharedlib\*.lib move sharedlib\*.lib %DstDir%\
if exist sharedlib\*.dll move sharedlib\*.dll %DstDir%\
if exist sharedlib\jpeg.pdb move sharedlib\jpeg.pdb %DstDir%\

if exist *.exe move *.exe %DstDir%\exe\
if exist *.pdb move *.pdb %DstDir%\exe\
if exist sharedlib\*.exe move sharedlib\*.exe %DstDir%\exe\
if exist sharedlib\*.pdb move sharedlib\*.pdb %DstDir%\exe\

if "%LibCopyDir%"=="" goto ENDIF_LibCopyDir
if not exist %LibCopyDir% mkdir %LibCopyDir%
if not exist %LibCopyDir%\%Target% mkdir %LibCopyDir%\%Target%
rem if exist %DstDir%\*.lib copy %DstDir%\*.lib %LibCopyDir%\%Target%
rem if exist %DstDir%\*.dll copy %DstDir%\*.dll %LibCopyDir%\%Target%
rem if exist %DstDir%\*.pdb copy %DstDir%\*.pdb %LibCopyDir%\%Target%
if exist %DstDir%\jpeg-static.lib copy %DstDir%\jpeg-static.lib %LibCopyDir%\%Target%\mozjpeg-static.lib
if exist %DstDir%\turbojpeg-static.lib copy %DstDir%\turbojpeg-static.lib %LibCopyDir%\%Target%\mozturbojpeg-static.lib
:ENDIF_LibCopyDir

cd ..

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
set TgtReplFile=%1
set BakReplFile=%1.bak
if exist %BakReplFile% del %BakReplFile%
move %TgtReplFile% %BakReplFile%
type nul >%TgtReplFile%
for /f "delims=" %%A in (%BakReplFile%) do (
    set line=%%A
    call :Rep1SubMTtoMD
)
exit /b
:Rep1SubMTtoMD
echo %line:/MT=/MD%>>%TgtReplFile%
exit /b


:ReplaceMDtoMT
for /R %%i in (CMakeCache.txt) do (
  if exist %%i call :Rep1MDtoMT %%i
)
exit /b
:Rep1MDtoMT
set TgtReplFile=%1
set BakReplFile=%1.bak
if exist %BakReplFile% del %BakReplFile%
move %TgtReplFile% %BakReplFile%
type nul >%TgtReplFile%
for /f "delims=" %%A in (%BakReplFile%) do (
    set line=%%A
    call :Rep1SubMDtoMT
)
exit /b
:Rep1SubMDtoMT
echo %line:/MD=/MT%>>%TgtReplFile%
exit /b
