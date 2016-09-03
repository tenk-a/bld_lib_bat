rem @echo off
rem Compile opencv(libssl,libcrypto) for vc
rem usage: bld1_opencv [win32/x64] [static/rtdll/dll] [libcopy:DEST_DIR]
rem ex)
rem cd libharu-RELEASE_2_3_0
rem ..\bld_lib_bat\bld1_libharu.bat
rem
rem This batch-file license: boost software license version 1.0
setlocal

set Arch=%CcArch%
set LibDir=%CcLibDir%
rem set LibCopyDir=
set StrPrefix=%CcLibPrefix%
rem set StrRel=%CcLibStrRelease%
rem set StrDbg=%CcLibStrDebug%
set StrDll=_dll
set StrRtSta=%CcLibStrStatic%
set StrRtDll=%CcLibStrRtDll%
set LibRootDir=%~dp0..

rem set HasRel=
rem set HasDbg=
set HasRtSta=
rem set HasRtDll=
set HasDll=

set LibArchX86=%CcLibArchX86%
if "%LibArchX86%"=="" set LibArchX86=Win32

:ARG_LOOP
  if "%1"=="" goto ARG_LOOP_EXIT

  if /I "%1"=="x86"      set Arch=%LibArchX86%
  if /I "%1"=="win32"    set Arch=%LibArchX86%
  if /I "%1"=="x64"      set Arch=x64

  if /I "%1"=="dll"      set HasDll=D
  if /I "%1"=="static"   set HasRtSta=S
  if /I "%1"=="rtsta"    set HasRtSta=S
  if /I "%1"=="rtdll"    set HasRtDll=L

  if /I "%1"=="release"  set HasRel=r
  rem if /I "%1"=="debug"    set HasDbg=d

  set ARG=%1
  if /I "%ARG:~0,8%"=="LibCopy:"    set LibCopyDir=%ARG:~8%
  if /I "%ARG:~0,7%"=="LibDir:"     set LibDir=%ARG:~7%
  if /I "%ARG:~0,10%"=="LibPrefix:" set StrPrefix=%ARG:~10%
  if /I "%ARG:~0,7%"=="LibDll:"     set StrDll=%ARG:~7%
  if /I "%ARG:~0,9%"=="LibRtSta:"   set StrRtSta=%ARG:~9%
  if /I "%ARG:~0,9%"=="LibRtDll:"   set StrRtDll=%ARG:~9%
  rem if /I "%ARG:~0,7%"=="LibRel:"     set StrRel=%ARG:~7%
  rem if /I "%ARG:~0,7%"=="LibDbg:"     set StrDbg=%ARG:~7%
  shift
goto ARG_LOOP
:ARG_LOOP_EXIT

if "%Arch%"=="" (
  if /I not "%PATH:Microsoft Visual Studio 14.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 12.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 11.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 10.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 9.0\VC\BIN\amd64=%"=="%PATH%"  set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 8\VC\BIN\amd64=%"=="%PATH%"    set Arch=x64
)
if "%Arch%"=="" set Arch=%LibArchX86%

if "%HasRtSta%%HasDll%"=="" (
  set HasRtSta=S
  set HasRtDll=L
  rem set HasDll=D
)

if "%LibDir%"=="" set LibDir=lib
if not "%LibCopyDir%"=="" set LibDir=%LibCopyDir%

if not exist %LibDir% mkdir %LibDir%

if not exist bin mkdir bin

if "%HasRtSta%"=="S" call :Bld1 rtsta %StrPrefix%%Arch%%StrRtSta%
if "%HasRtDll%"=="L" call :Bld1 rtdll %StrPrefix%%Arch%%StrRtDll%
if "%HasDll%"=="D"   call :Bld1 dll   %StrPrefix%%Arch%%StrDll%

endlocal
goto :EOF


:Bld1
set TgtType=%1
set Target=%2

set ArchType=VC-WIN32
if "%Arch%"=="x64" set ArchType=VC-WIN64A

set ShardOpt=no-shared
if "%TgtType%"=="dll" set ShardOpt=shared

perl Configure %ArchType% %ShardOpt%

nmake clean

if not "%TgtType%"=="rtdll" goto SKIP1
..\bld_lib_bat\tiny_replstr -x ++ /MT /MD -- makefile
:SKIP1

nmake


if "%TgtType%"=="dll" goto SKIP_TO_DLL

set DstDir=%LibDir%\%Target%_release
if not exist %DstDir% mkdir %DstDir%

if exist libssl.lib copy libssl.lib %DstDir%\
if exist libssl.pdb copy libssl.pdb %DstDir%\
if exist libcrypto.lib copy libcrypto.lib %DstDir%\
if exist libcrypto.pdb copy libcrypto.pdb %DstDir%\

set DstDir=%LibDir%\%Target%_debug
if not exist %DstDir% mkdir %DstDir%

if exist libssl.lib copy libssl.lib %DstDir%\
if exist libssl.pdb copy libssl.pdb %DstDir%\
if exist libcrypto.lib copy libcrypto.lib %DstDir%\
if exist libcrypto.pdb copy libcrypto.pdb %DstDir%\

goto SKIP_END
:SKIP_TO_DLL

set DstDir=%LibDir%\%Target%
if not exist %DstDir% mkdir %DstDir%

if exist libssl*.lib copy libssl*.lib %DstDir%\
if exist libssl*.dll copy libssl*.dll %DstDir%\
if exist libssl*.pdb copy libssl*.pdb %DstDir%\
if exist libcrypto*.lib copy libcrypto*.lib %DstDir%\
if exist libcrypto*.dll copy libcrypto*.dll %DstDir%\
if exist libcrypto*.pdb copy libcrypto*.pdb %DstDir%\

if not exist %DstDir%\engines mkdir %DstDir%\engines
if exist engines\*.lib move engines\*.lib %DstDir%\engines\
if exist engines\*.dll move engines\*.dll %DstDir%\engines\
if exist engines\*.pdb move engines\*.pdb %DstDir%\engines\

:SKIP_END

nmake distclean

exit /b
