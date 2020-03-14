@echo off
rem This batch-file license: boost software license version 1.0
setlocal
set LibRootDir=%~dp0..

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
  rem set HasDll=D
)
if "%HasRel%%HasDbg%"=="" (
  set HasRel=r
  set HasDbg=d
)

if not exist bin mkdir bin

if "%HasRtSta%%HasRel%"=="Sr" call :Bld1 static release
if "%HasRtDll%%HasRel%"=="Lr" call :Bld1 rtdll  release
if "%HasDll%"=="Dr"   call :Bld1 dll releae


if "%HasRtSta%%HasDbg%"=="Sd" call :Bld1 static debug
if "%HasRtDll%%HasDbg%"=="Ld" call :Bld1 rtdll  debug
if "%HasDll%"=="Dd"   call :Bld1 dll debug

goto END


:Bld1
set Rt=%1
set Conf=%2

set StrLibPath=
call %CcBatDir%\sub\StrLibPath.bat %CcTgtLibPathType% _ %VcVer% %Arch% %Rt% %Conf%
set Target=%StrLibPath%

set DstDir=%CcTgtLibDir%\%Target%

if %Conf%==debug goto BLD1_SKIP1
set StrLibPath=
call %CcBatDir%\sub\StrLibPath.bat %CcTgtLibPathType% _ %VcVer% %Arch% %Rt% release
set reldir=%CcTgtLibDir%\%StrLibPath%
if not exist %reldir% goto BLD1_SKIP1
copy /b %reldir%\*.* %DstDir%\
exit /b
:BLD1_SKIP1

set ArchType=VC-WIN32
if "%Arch%"=="x64" set ArchType=VC-WIN64A

set ShardOpt=no-shared
if "%Conf%"=="dll" set ShardOpt=shared

perl Configure %ArchType% %ShardOpt%

nmake clean

if not "%Conf%"=="rtdll" goto SKIP1
%CcBatDir\tiny_replstr -x ++ /MT /MD -- makefile
:SKIP1

nmake

set DstDir=%CcTgtLibDir%\%Target%
if not exist %DstDir% mkdir %DstDir%

if "%Conf%"=="dll" goto SKIP_TO_DLL

if exist libssl.lib copy libssl.lib %DstDir%\
if exist libssl.pdb copy libssl.pdb %DstDir%\
if exist libcrypto.lib copy libcrypto.lib %DstDir%\
if exist libcrypto.pdb copy libcrypto.pdb %DstDir%\

goto SKIP_END
:SKIP_TO_DLL

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

:END
endlocal
