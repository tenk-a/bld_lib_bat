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
set LibDir=
set StrPrefix=
set StrRel=_release
set StrDbg=_debug
set StrRtSta=_static
set StrRtDll=

:ARG_LOOP
  set ARG=%1

  if "%ARG%"=="" goto ARG_LOOP_EXIT
  if /I "%ARG%"=="static"   set HasRtSta=S
  if /I "%ARG%"=="rtdll"    set HasRtDll=L
  if /I "%ARG%"=="release"  set HasRel=r
  rem if /I "%ARG%"=="debug"    set HasDbg=d
  if /I "%ARG%"=="test"     set HasTest=1

  if /I "%ARG:~0,7%"=="LibDir:"     set LibDir=%ARG:~7%
  if /I "%ARG:~0,10%"=="LibPrefix:" set StrPrefix=%ARG:~10%
  if /I "%ARG:~0,9%"=="LibRtSta:"   set StrRtSta=%ARG:~9%
  if /I "%ARG:~0,9%"=="LibRtDll:"   set StrRtDll=%ARG:~9%
  rem if /I "%ARG:~0,7%"=="LibRel:"     set StrRel=%ARG:~7%
  rem if /I "%ARG:~0,7%"=="LibDbg:"     set StrDbg=%ARG:~7%

  shift
goto ARG_LOOP
:ARG_LOOP_EXIT

if "%StrPrefix%"=="" (
  if not "%VcVer%"=="" (
    if "%StrPrefix%"=="" set StrPrefix=%VcVer%_
  )
)

if "%HasRtSta%%HasRtDll%"=="" (
  set HasRtSta=S
  set HasRtDll=L
  rem set HasDll=D
)
if "%HasRel%%HasDbg%"=="" (
  set HasRel=r
  set HasDbg=d
)

if "%LibDir%"=="" set LibDir=lib
if not exist %LibDir% mkdir %LibDir%

if not exist bin mkdir bin

if "%HasRtSta%"=="S" call :Bld1 rtsta %StrPrefix%%Arch%%StrRtSta%
if "%HasRtDll%"=="L" call :Bld1 rtdll %StrPrefix%%Arch%%StrRtDll%
if "%HasDll%"=="D"   call :Bld1 dll   %StrPrefix%%Arch%%StrDll%

goto END


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

set DstDir=%LibDir%\%Target%
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

:END
endlocal
