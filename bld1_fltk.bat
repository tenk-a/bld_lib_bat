rem @echo off
rem Compile fltk for vc
rem This batch-file license: boost software license version 1.0
setlocal

set Arch=
set LibDir=lib
set StrPrefix=
set StrRtSta=_static
set StrRtDll=

set HasRtSta=
set HasRtDll=
set VcVer=
set VcSlnDir=

:ARG_LOOP
  if "%1"=="" goto ARG_LOOP_EXIT

  if /I "%1"=="x86"      set Arch=Win32
  if /I "%1"=="win32"    set Arch=Win32
  if /I "%1"=="x64"      set Arch=x64

  if /I "%1"=="static"   set HasRtSta=S
  if /I "%1"=="rtsta"    set HasRtSta=S
  if /I "%1"=="rtdll"    set HasRtDll=L

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

  shift
goto ARG_LOOP
:ARG_LOOP_EXIT

rem if /I not "%PATH:Microsoft Visual Studio 13.0=%"=="%PATH%" set VcVer=vc13
if /I not "%PATH:Microsoft Visual Studio\2017=%"=="%PATH%" (
    set VcVer=vc141
    set VcSlnDir=VisualC2017
)
if /I not "%PATH:Microsoft Visual Studio 14.0=%"=="%PATH%" (
    set VcVer=vc140
    set VcSlnDir=VisualC2015
)
if /I not "%PATH:Microsoft Visual Studio 12.0=%"=="%PATH%" (
    set VcVer=vc120
    set VcSlnDir=VisualC2013
)
if /I not "%PATH:Microsoft Visual Studio 11.0=%"=="%PATH%" (
    set VcVer=vc110
    set VcSlnDir=VisualC2012
)
if /I not "%PATH:Microsoft Visual Studio 10.0=%"=="%PATH%" (
    set VcVer=vc100
    set VcSlnDir=VisualC2010
)
if /I not "%PATH:Microsoft Visual Studio 9.0=%"=="%PATH%" (
    set VcVer=vc90
    set VcSlnDir=VisualC2008
)
if /I not "%PATH:Microsoft Visual Studio 8=%"=="%PATH%" (
    set VcVer=vc80
    set VcSlnDir=VisualC2005
)
if "%VcVer%"=="" (
  echo unkown compiler
  goto END
)

call :Clean

if "%Arch%"=="" (
  if /I not "%PATH:Microsoft Visual Studio 14.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 13.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 12.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 11.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 10.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 9.0\VC\BIN\amd64=%"=="%PATH%"  set Arch=x64
  rem if /I not "%PATH:Microsoft Visual Studio 8\VC\BIN\amd64=%"=="%PATH%"    set Arch=x64
)
if "%Arch%"=="" set Arch=Win32
set Platform=%Arch%
if "%Platform%"=="x86" set Platform=Win32

if not exist "ide\%VcSlnDir%" (
  if "%VcVer%"=="vc141" call ..\bld_lib_bat\sub\UpgradeFltkIdeVcproj.bat %VcSlnDir%
  if "%VcVer%"=="vc140" call ..\bld_lib_bat\sub\UpgradeFltkIdeVcproj.bat %VcSlnDir%
  if "%VcVer%"=="vc130" call ..\bld_lib_bat\sub\UpgradeFltkIdeVcproj.bat %VcSlnDir%
  if "%VcVer%"=="vc120" call ..\bld_lib_bat\sub\UpgradeFltkIdeVcproj.bat %VcSlnDir%
  if "%VcVer%"=="vc110" call ..\bld_lib_bat\sub\UpgradeFltkIdeVcproj.bat %VcSlnDir%
  if not exist "ide\%VcSlnDir%" (
     echo not found ide\%VcSlnDir% directory
     goto :EOF
  )
)

if not "%Platform%"=="x64" goto SKIP_X64_DIR_CHECK
set DstDir=%VcSlnDir%%Platform%
if not exist "ide\%DstDir%" (
  mkdir ide\%DstDir%
  copy ide\%VcSlnDir%\*.* ide\%DstDir%\
  call :ReplaceWin32toX64 ide\%DstDir%
)
set VcSlnDir=%DstDir%
:SKIP_X64_DIR_CHECK

if "%HasRtSta%%HasRtDll%"=="" (
  set HasRtSta=S
  set HasRtDll=L
)

if "%StrRtSta%%StrRtDll%"=="" set StrRtSta=_static

if "%LibDir%"=="" set LibDir=lib
if not exist %LibDir% mkdir %LibDir%

if "%HasRtDll%"=="L" (
  call :Bld1 release %StrPrefix%%Arch%%StrRtDll%
  call :Bld1 debug   %StrPrefix%%Arch%%StrRtDll%
)

if not "%HasRtSta%"=="S" goto SKIP_STATIC_BLD
set DstDir=%VcSlnDir%_static
if not exist %DstDir% (
  mkdir ide\%DstDir%
  copy ide\%VcSlnDir%\*.* ide\%DstDir%\
  call :ReplaceMDtoMT ide\%DstDir%
)
set VcSlnDir=%DstDir%
call :Bld1 release %StrPrefix%%Arch%%StrRtSta%
call :Bld1 debug   %StrPrefix%%Arch%%StrRtSta%
:SKIP_STATIC_BLD

endlocal
goto :EOF



:Bld1
set BldType=%1
set Target=%2

pushd ide\%VcSlnDir%

msbuild fltk.sln /t:Rebuild /p:Configuration=%BldType% /p:Platform=%Platform%

for /D %%i in (*_release *_debug) do (
  del /Q /F /S %%i\*.*
  rmdir /S /Q %%i
)

popd

set SrcDir=lib
set DstDir=%LibDir%\%Target%
if not exist %DstDir% mkdir %DstDir%

for %%i in (%SrcDir%\*.lib) do (
  if not %%i==%SrcDir%\README.lib move %%i %DstDir%\
)
if exist %SrcDir%\*.bsc move %SrcDir%\*.bsc %DstDir%\

set SrcDir=test
set DstDir=test\%Target%
if not exist %DstDir% mkdir %DstDir%

if /I exist %SrcDir%\*.exe move %SrcDir%\*.exe %DstDir%\
if /I exist %SrcDir%\*.dll move %SrcDir%\*.dll %DstDir%\
if /I exist %SrcDir%\*.pdb move %SrcDir%\*.pdb %DstDir%\
if /I exist %SrcDir%\*.lib move %SrcDir%\*.lib %DstDir%\
del %SrcDir%\*.exp %SrcDir%\*.ilk


set SrcDir=Fluid
set DstDir=Fluid\%Target%
if not exist %DstDir% mkdir %DstDir%

if /I exist %SrcDir%\*.exe move %SrcDir%\*.exe %DstDir%\
if /I exist %SrcDir%\*.pdb move %SrcDir%\*.pdb %DstDir%\

exit /b


:ReplaceWin32toX64
pushd %1
for %%i in (*.sln *.vcxproj) do (
  call :Replace1Win32toX64 %%i
)
popd
exit /b

:Replace1Win32toX64
set TgtReplFile=%1
set BakReplFile=%1.bak
if exist %BakReplFile% del %BakReplFile%
move %TgtReplFile% %BakReplFile% 
..\..\..\bld_lib_bat\tiny_replstr.exe ++ Win32 X64  MachineX86 MachineX64 -- %BakReplFile% >%TgtReplFile%
del /S *.bak
exit /b

:ReplaceMDtoMT
pushd %1
for %%i in (*.sln *.vcxproj) do (
  call :Replace1MDtoMT %%i
)
popd
exit /b

:Replace1MDtoMT
set TgtReplFile=%1
set BakReplFile=%1.bak
if exist %BakReplFile% del %BakReplFile%
move %TgtReplFile% %BakReplFile% 
..\..\..\bld_lib_bat\tiny_replstr.exe ++ MultiThreadedDebugDLL MultiThreadedDebug  MultiThreadedDLL MultiThreaded  "<IgnoreSpecificDefaultLibraries>libcd;" "<IgnoreSpecificDefaultLibraries>"  "<IgnoreSpecificDefaultLibraries>libcmt;" "<IgnoreSpecificDefaultLibraries>"  "<IgnoreSpecificDefaultLibraries>libcmt;" "<IgnoreSpecificDefaultLibraries>"  "<IgnoreSpecificDefaultLibraries>libcmtd;" "<IgnoreSpecificDefaultLibraries>" -- %BakReplFile% >%TgtReplFile%
del /S *.bak
exit /b

:Clean
del /s /f *.bak *.obj *.ilk
cd ide
for /R /D %%i in (*_release *_debug) do (
  del /Q /F /S %%i\*.*
  rmdir /S /Q %%i
)
cd ..
exit /b
