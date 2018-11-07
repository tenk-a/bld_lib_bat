@echo off
rem Compile mozjpeg for vc
rem usage: bld1_mozjpeg [win32/x64] [debug/release] [clean]
rem ex)
rem cd mozjpeg
rem ..\bld_lib_bat\bld1_mozjpeg.bat x64
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
rem set HasTest=
set CleanMode=
set VcVer=

:ARG_LOOP
  if "%1"=="" goto ARG_LOOP_EXIT

  if /I "%1"=="x86"      set Arch=Win32
  if /I "%1"=="Win32"    set Arch=Win32
  if /I "%1"=="x64"      set Arch=x64

  if /I "%1"=="static"   set HasRtSta=S
  if /I "%1"=="rtsta"    set HasRtSta=S
  if /I "%1"=="rtdll"    set HasRtDll=L

  if /I "%1"=="release"  set HasRel=r
  if /I "%1"=="debug"    set HasDbg=d

  if /I "%1"=="clean"    set CleanMode=1

  rem if /I "%1"=="test"     set HasTest=1

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
  if /I not "%PATH:Microsoft Visual Studio 14.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 13.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 12.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 11.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 10.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 9.0\VC\BIN\amd64=%"=="%PATH%"  set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 8\VC\BIN\amd64=%"=="%PATH%"    set Arch=x64
)
if "%Arch%"=="" set Arch=Win32

if not exist bld mkdir bld


if "%CleanMode%"=="1" (
  pushd bld
  call :Clean
  popd
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

if "%LibDir%"=="" set LibDir=lib

pushd bld
if "%HasRtSta%%HasRel%"=="Sr" call :Bld1 rtsta release %StrPrefix%%Arch%%StrRtSta%%StrRel%
if "%HasRtSta%%HasDbg%"=="Sd" call :Bld1 rtsta debug   %StrPrefix%%Arch%%StrRtSta%%StrDbg%
if "%HasRtDll%%HasRel%"=="Lr" call :Bld1 rtdll release %StrPrefix%%Arch%%StrRtDll%%StrRel%
if "%HasRtDll%%HasDbg%"=="Ld" call :Bld1 rtdll debug   %StrPrefix%%Arch%%StrRtDll%%StrDbg%
popd

goto END


:Bld1
set RtType=%1
set BldType=%2
set Target=%3

if not exist %Target% mkdir %Target%

pushd %Target%
set DstBaseDir=..\..

call :Clean

set ADD_CMAKE_OPTS=
if %RtType%==rtdll (
    set ADD_CMAKE_OPTS=-DWITH_CRT_DLL=true
) else (
    set ADD_CMAKE_OPTS=-DWITH_CRT_DLL=false
)
CMake -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=%BldType% %ADD_CMAKE_OPTS% %DstBaseDir%\
if errorlevel 1 (
  popd
  exit /b
)

rem if %RtType%==rtdll (
rem   call :ReplaceMTtoMD
rem )
if %RtType%==rtsta (
    call :ReplaceMDtoMT
)

nmake
if errorlevel 1 (
  popd
  exit /b
)

set DstLibDir=%DstBaseDir%\%LibDir%
if not exist %DstLibDir% mkdir %DstLibDir%
set DstLibDir=%DstLibDir%\%Target%

set DstExeDir=%DstBaseDir%\exe
if not exist %DstExeDir% mkdir %DstExeDir%
set DstExeDir=%DstExeDir%\%Target%

del *.obj *.exp *.ilk *.res *.resource.txt *.manifest

if not exist %DstBaseDir%\jconfig.h    copy jconfig.h    %DstBaseDir%\
if not exist %DstBaseDir%\jconfigint.h copy jconfigint.h %DstBaseDir%\

if exist *.lib move *.lib %DstLibDir%\
if exist *.dll move *.dll %DstLibDir%\
if exist turbojpeg.pdb move turbojpeg.pdb %DstLibDir%\
if exist sharedlib\*.lib move sharedlib\*.lib %DstLibDir%\
if exist sharedlib\*.dll move sharedlib\*.dll %DstLibDir%\
if exist sharedlib\jpeg.pdb move sharedlib\jpeg.pdb %DstLibDir%\

if exist *.exe move *.exe %DstExeDir%\
if exist *.pdb move *.pdb %DstExeDir%\
if exist sharedlib\*.exe move sharedlib\*.exe %DstExeDir%\
if exist sharedlib\*.pdb move sharedlib\*.pdb %DstExeDir%\

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

:END
endlocal
