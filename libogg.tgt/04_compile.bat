rem @echo off
rem This batch-file license: boost software license version 1.0
rem for libogg v.1.3.4
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
  if /I "%ARG%"=="debug"    set HasDbg=d
  rem if /I "%ARG%"=="test"     set HasTest=1

  if /I "%ARG:~0,7%"=="LibDir:"     set LibDir=%ARG:~7%
  if /I "%ARG:~0,10%"=="LibPrefix:" set StrPrefix=%ARG:~10%
  if /I "%ARG:~0,9%"=="LibRtSta:"   set StrRtSta=%ARG:~9%
  if /I "%ARG:~0,9%"=="LibRtDll:"   set StrRtDll=%ARG:~9%
  if /I "%ARG:~0,7%"=="LibRel:"     set StrRel=%ARG:~7%
  if /I "%ARG:~0,7%"=="LibDbg:"     set StrDbg=%ARG:~7%

  shift
goto ARG_LOOP
:ARG_LOOP_EXIT

if "%HasRtSta%%HasRtDll%"=="" (
  set HasRtSta=S
  set HasRtDll=L
)
if "%HasRel%%HasDbg%"=="" (
  set HasRel=r
  set HasDbg=d
)


if "%Arch%"=="" set Arch=Win32

set SlnDir=
if "%VcVer%"=="vc142" set SlnDir=VS2019
if "%VcVer%"=="vc141" set SlnDir=VS2017
if "%VcVer%"=="vc140" set SlnDir=VS2015
rem if "%VcVer%"=="vc130" set SlnDir=VS2014
rem if "%VcVer%"=="vc120" set SlnDir=VS2013
rem if "%VcVer%"=="vc110" set SlnDir=VS2012
rem if "%VcVer%"=="vc100" set SlnDir=VS2010
rem if "%VcVer%"=="vc90"  set SlnDir=VS2008
rem if "%VcVer%"=="vc80"  set SlnDir=VS2005
rem if "%VcVer%"=="vc71"  set SlnDir=VS2003
if "%SlnDir%"=="" (
  echo ERROR: libogg 1.3.4: vs2015 or later
  goto ERR
)

if not exist win32\%SlnDir% (
  if "%SlnDir%"=="VS2019" call :SlnCopyUpd VS2015 VS2019
  if "%SlnDir%"=="VS2017" call :SlnCopyUpd VS2015 VS2017
  rem if "%SlnDir%"=="VS2015" call :SlnCopyUpd VS2010 VS2015
  rem if "%SlnDir%"=="VS2013" call :SlnCopyUpd VS2010 VS2013
  rem if "%SlnDir%"=="VS2012" call :SlnCopyUpd VS2010 VS2012
  if not exist win32\%SlnDir% (
     echo Not found win32\%SlnDir% directory.
     goto ERR
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

if "%HasRtDll%"=="L" call :gen_rtdll_sln

if "%HasRtDll%%HasRel%"=="Lr" call :Bld1 release %SlnDir%_rtdll
if "%HasRtDll%%HasDbg%"=="Ld" call :Bld1 debug   %SlnDir%_rtdll
if "%HasRtSta%%HasRel%"=="Sr" call :Bld1 release %SlnDir%
if "%HasRtSta%%HasDbg%"=="Sd" call :Bld1 debug   %SlnDir%

goto :END

:Bld1
set Conf=%1
set sdir=%2
echo %sdir%
pushd win32\%sdir%
msbuild libogg.sln  /t:Rebuild /p:Configuration=%Conf% /p:Platform=%Arch%
if exist %Arch%\%Conf%\libogg.lib copy %Arch%\%Conf%\libogg.lib %Arch%\%Conf%\libogg_static.lib
popd

exit /b

:gen_rtdll_sln
pushd win32
if not exist %SlnDir%_rtdll mkdir %SlnDir%_rtdll
copy /b %SlnDir%\*.* %SlnDir%_rtdll\
..\..\bld_lib_bat\tiny_replstr -x ++ MultiThreaded MultiThreadedDLL MultiThreadedDebug MultiThreadedDebugDLL -- %SlnDir%_rtdll\libogg.vcxproj
popd
exit /b

:SlnCopyUpd
cd win32
mkdir %2
copy %1\*.* %2\
cd %2
devenv /Upgrade libogg.sln
call :DelBackup
cd ..
cd ..
exit /b

:DelBackup
del UpgradeLog.htm
del /S /Q /F Backup\*.*
rmdir /S /Q Backup
exit /b

:ERR
endlocal
exit /b 1

:END
endlocal
