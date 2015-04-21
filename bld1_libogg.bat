rem @echo off
rem Compile libogg for vc
rem This batch-file license: boost software license version 1.0
setlocal

set Arch=%CcArch%
set LibDir=%CcLibDir%
set LibCopyDir=
set StrPrefix=%CcLibPrefix%
set StrRel=%CcLibStrRelease%
set StrDbg=%CcLibStrDebug%
set StrRtSta=%CcLibStrRtStatic%
set StrRtDll=%CcLibStrRtDll%

set HasRel=
set HasDbg=
set HasRtSta=
set HasRtDll=
set Compiler=

:ARG_LOOP
  if "%1"=="" goto ARG_LOOP_EXIT

  if /I "%1"=="vc71"    set Compiler=vc71
  if /I "%1"=="vc8"     set Compiler=vc8
  if /I "%1"=="vc9"     set Compiler=vc9
  if /I "%1"=="vc10"    set Compiler=vc10
  if /I "%1"=="vc11"    set Compiler=vc11
  if /I "%1"=="vc12"    set Compiler=vc12
  rem if /I "%1"=="vc13"    set Compiler=vc13

  if /I "%1"=="x86"      set Arch=x86
  if /I "%1"=="x64"      set Arch=x64

  if /I "%1"=="static"   set HasRtSta=S
  if /I "%1"=="rtsta"    set HasRtSta=S
  if /I "%1"=="rtdll"    set HasRtDll=L

  if /I "%1"=="release"  set HasRel=r
  if /I "%1"=="debug"    set HasDbg=d

  set ARG=%1
  if /I "%ARG:~0,7%"=="libdir:" set LibDir=%ARG:~7%
  if /I "%ARG:~0,8%"=="libcopy:" set LibCopyDir=%ARG:~8%

  shift
goto ARG_LOOP
:ARG_LOOP_EXIT

if "%Compiler%"=="" (
  rem if /I not "%PATH:Microsoft Visual Studio 13.0=%"=="%PATH%" set Compiler=vc13
  if /I not "%PATH:Microsoft Visual Studio 12.0=%"=="%PATH%" set Compiler=vc12
  if /I not "%PATH:Microsoft Visual Studio 11.0=%"=="%PATH%" set Compiler=vc11
  if /I not "%PATH:Microsoft Visual Studio 10.0=%"=="%PATH%" set Compiler=vc10
  if /I not "%PATH:Microsoft Visual Studio 9.0=%"=="%PATH%"  set Compiler=vc9
  if /I not "%PATH:Microsoft Visual Studio 8=%"=="%PATH%"    set Compiler=vc8
  if /I not "%PATH:Microsoft Visual Studio .NET 2003=%"=="%PATH%" set Compiler=vc71
)
if "%Compiler%"=="" (
  echo unkown compiler
  goto END
)

if "%Arch%"=="" (
  rem if /I not "%PATH:Microsoft Visual Studio 13.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 12.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 11.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 10.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 9.0\VC\BIN\amd64=%"=="%PATH%"  set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 8\VC\BIN\amd64=%"=="%PATH%"    set Arch=x64
)
if "%Arch%"=="" set Arch=x86
set Platform=%Arch%
if "%Platform%"=="x86" set Platform=Win32

set SlnDir=
rem if "%Compiler%"=="vs13" set SlnDir=VS2014
if "%Compiler%"=="vc12" set SlnDir=VS2013
if "%Compiler%"=="vc11" set SlnDir=VS2012
if "%Compiler%"=="vc10" set SlnDir=VS2010
if "%Compiler%"=="vc9"  set SlnDir=VS2008
if "%Compiler%"=="vc8"  set SlnDir=VS2005
if "%Compiler%"=="vc71" set SlnDir=VS2003

if not exist win32\%SlnDir% (
  if "%SlnDir%"=="VS2013" call :SlnCopyUpd VS2010 VS2013
  if "%SlnDir%"=="VS2012" call :SlnCopyUpd VS2010 VS2012
  if not exist win32\%SlnDir% (
     echo not found win32\%SlnDir% directory
     goto END
  )
)

if "%HasRtSta%%HasRtDll%"=="" (
  set HasRtSta=S
  set HasRtDll=L
)
if "%HasRel%%HasDbg%"=="" (
  set HasRel=r
  set HasDbg=d
)

if "%StrRel%%StrDbg%"==""     set StrDbg=_debug
if "%StrRtSta%%StrRtDll%"=="" set StrRtSta=_static

if "%LibDir%"=="" set LibDir=lib
if not exist %LibDir% mkdir %LibDir%

if "%HasRtSta%%HasRel%"=="Sr" call :Bld1 release MultiThreaded          %StrPrefix%%Arch%%StrRtSta%%StrRel%
if "%HasRtSta%%HasDbg%"=="Sd" call :Bld1 debug   MultiThreadedDebug     %StrPrefix%%Arch%%StrRtSta%%StrDbg%
if "%HasRtDll%%HasRel%"=="Lr" call :Bld1 release MultiThreadedDLL       %StrPrefix%%Arch%%StrRtDll%%StrRel%
if "%HasRtDll%%HasDbg%"=="Ld" call :Bld1 debug   MultiThreadedDebugDLL  %StrPrefix%%Arch%%StrRtDll%%StrDbg%

endlocal
goto :EOF


:Bld1
set BldType=%1
set RtStr=%2
set Target=%3

cd win32\%SlnDir%

msbuild libogg_static.vcxproj  /t:Rebuild /p:Configuration=%BldType% /p:Platform=%Platform% /p:RuntimeLibrary=%RtStr%
msbuild libogg_dynamic.vcxproj /t:Rebuild /p:Configuration=%BldType% /p:Platform=%Platform% /p:RuntimeLibrary=%RtStr%

cd ..\..

set SrcDir=win32\%SlnDir%\%Platform%\%BldType%

set DstDir=%LibDir%\%Target%
if not exist %DstDir% mkdir %DstDir%

if /I exist %SrcDir%\*.lib move %SrcDir%\*.lib %DstDir%\
if /I exist %SrcDir%\*.dll move %SrcDir%\*.dll %DstDir%\
if /I exist %SrcDir%\*.pdb move %SrcDir%\*.pdb %DstDir%\

if "%LibCopyDir%"=="" goto ENDIF_LibCopyDir
if not exist %LibCopyDir% mkdir %LibCopyDir%
if not exist %LibCopyDir%\%Target% mkdir %LibCopyDir%\%Target%
if exist %DstDir%\*.lib copy %DstDir%\*.lib %LibCopyDir%\%Target%
if exist %DstDir%\*.dll copy %DstDir%\*.dll %LibCopyDir%\%Target%
if exist %DstDir%\*.pdb copy %DstDir%\*.pdb %LibCopyDir%\%Target%
:ENDIF_LibCopyDir

exit /b


:SlnCopyUpd
cd win32
mkdir %2
copy %1\*.* %2\
cd %2
devenv /Upgrade libogg_dynamic.sln
devenv /Upgrade libogg_static.sln
cd ..
cd ..
exit /b


