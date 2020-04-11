rem @echo on
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
)
if "%HasRel%%HasDbg%"=="" (
  set HasRel=r
  set HasDbg=d
)

set CurDir=%CD%

if "%HasRtSta%%HasRel%"=="Sr" call :Bld1 static release
if "%HasRtSta%%HasDbg%"=="Sd" call :Bld1 static debug
if "%HasRtDll%%HasRel%"=="Lr" call :Bld1 rtdll  release
if "%HasRtDll%%HasDbg%"=="Ld" call :Bld1 rtdll  debug

goto END


:Bld1
set Rt=%1
set Conf=%2

set VcName2=
if "%VcVer%"=="vc142" set VcName2=vc2019
rem if "%VcVer%"=="vc141" set SlnDir=vc2017
rem if "%VcVer%"=="vc140" set SlnDir=vc2015

if "%VcName2%"=="" (
 echo Need vc14.2[vc2019]
 exit /b
)

set SlnDir=%VcName2%
if not "%Rt%"=="rtdll" goto SKIP2
set SlnDir=%VcName2%.rtdll
if not exist proj\%SlnDir%\Cinder.sln call :MkRtDll
:SKIP2

pushd proj\%SlnDir%

msbuild Cinder.sln /t:Rebuild /p:Configuration=%Conf% /p:Platform=%Arch% /maxcpucount

rem set StrLibPath=
rem call %CcBatDir%\sub\StrLibPath.bat %CcTgtLibPathType% %BaseDir%\%CcTgtLibDir% %VcVer% %Arch% %Rt% %Conf%
rem set TgtLibDir=%StrLibPath%
rem if not exist %TgtLibDir% mkdir %TgtLibDir%
rem if exist build\Release xcopy build\Release %TgtLibDir% /R /Y /I /K /E

exit /b

:MkRtDll
mkdir proj\%SlnDir%
xcopy proj\%VcName2% proj\%SlnDir% /R /Y /I /K /E
pushd proj\%SlnDir%
call :ReplaceMTtoMD
popd
exit /b

:ReplaceMTtoMD
for /r %%i in (*.vcxproj) do (
  if exist %%i call :Rep1MTtoMD %%i
)
exit /b

:Rep1MTtoMD
%CcBatDir%\tiny_replstr.exe -x ++ MultiThreadedDebugDLL MultiThreadedDebug MultiThreadedDLL MultiThreaded -- %1
%CcBatDir%\tiny_replstr.exe -x ++ MultiThreadedDebug @@@@@@@@DebugDLL MultiThreaded @@@@@@@@DLL -- %1
%CcBatDir%\tiny_replstr.exe -x ++ @@@@@@@@ MultiThreaded -- %1
exit /b


:END
endlocal
