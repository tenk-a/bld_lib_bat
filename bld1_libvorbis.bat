rem @echo off
rem Compile libogg for vc
rem This batch-file license: boost software license version 1.0
setlocal

set Arch=%CcArch%
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
set OggDir=
set SrcOggVerVc8=1.1.4
set SrcOggVerVc9=1.1.4
set SrcOggVerVc10=1.2.0

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
  if /I "%ARG:~0,8%"=="LibCopy:"    set LibCopyDir=%ARG:~8%
  if /I "%ARG:~0,7%"=="LibDir:"     set LibDir=%ARG:~7%
  if /I "%ARG:~0,10%"=="LibPrefix:" set StrPrefix=%ARG:~10%
  if /I "%ARG:~0,9%"=="LibRtStr:"   set StrRtStr=%ARG:~9%
  if /I "%ARG:~0,9%"=="LibRtDll:"   set StrRtDll=%ARG:~9%
  if /I "%ARG:~0,7%"=="LibRel:"     set StrRel=%ARG:~7%
  if /I "%ARG:~0,7%"=="LibDbg:"     set StrDbg=%ARG:~7%

  if /I "%ARG:~0,7%"=="OggDir:"     set OggDir=%ARG:~7%

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


if "%OggDir%"=="" (
  for /f %%i in ('dir /b /on /ad ..\libogg*') do set OggDir=%%i
)
set OggVar=%OggDir:libogg-=%
if "%OggVar%"=="%OggDir%" set OggVar=

if "%HasRtSta%%HasRtDll%"=="" (
  set HasRtSta=S
  set HasRtDll=L
)
if "%HasRel%%HasDbg%"=="" (
  set HasRel=r
  set HasDbg=d
)

if "%StrRtSta%%StrRtDll%"=="" set StrRtSta=_static

if "%HasRtDll%%HasRel%"=="Lr" call :Bld1 release rtdll  %StrPrefix%%Arch%%StrRtDll%%StrRel%
if "%HasRtDll%%HasDbg%"=="Ld" call :Bld1 debug   rtdll  %StrPrefix%%Arch%%StrRtDll%%StrDbg%
if "%HasRtSta%%HasRel%"=="Sr" call :Bld1 release static %StrPrefix%%Arch%%StrRtSta%%StrRel%
if "%HasRtSta%%HasDbg%"=="Sd" call :Bld1 debug   static %StrPrefix%%Arch%%StrRtSta%%StrDbg%

endlocal
goto :EOF


:Bld1
set BldType=%1
set RtType=%2
set Target=%3

pushd win32\%SlnDir%

if not "%OggVar%"=="" (
  if "%Compiler%"=="vc12" ..\..\..\bld_lib_bat\tiny_replstr -x ++ %SrcOggVerVc10% %OggVar% VS2010 VS2013 -- libogg.props
  if "%Compiler%"=="vc11" ..\..\..\bld_lib_bat\tiny_replstr -x ++ %SrcOggVerVc10% %OggVar% VS2010 VS2012 -- libogg.props
  if "%Compiler%"=="vc10" ..\..\..\bld_lib_bat\tiny_replstr -x ++ %SrcOggVerVc10% %OggVar% -- libogg.props
  if "%Compiler%"=="vc9"  ..\..\..\bld_lib_bat\tiny_replstr -x ++ %SrcOggVerVc9%  %OggVar% -- libogg.props
  if "%Compiler%"=="vc8"  ..\..\..\bld_lib_bat\tiny_replstr -x ++ %SrcOggVerVc8%  %OggVar% -- libogg.props
)
if %RtType%==static (
  call :gen_static
  msbuild vorbis_static.sln  /t:Rebuild /p:Configuration=%BldType% /p:Platform=%Platform%
) else (
  call :gen_rtdll
  msbuild vorbis_rtdll.sln   /t:Rebuild /p:Configuration=%BldType% /p:Platform=%Platform%
  msbuild vorbis_dynamic.sln /t:Rebuild /p:Configuration=%BldType% /p:Platform=%Platform%
)
popd

set SrcDir=win32\%SlnDir%\%Platform%\%BldType%
if "%LibCopyDir%"=="" goto ENDIF_LibCopyDir
if not exist %LibCopyDir% mkdir %LibCopyDir%
if not exist %LibCopyDir%\%Target% mkdir %LibCopyDir%\%Target%
if "%RtType%"=="static" (
  if exist %SrcDir%\libvorbis_static.lib copy %SrcDir%\libvorbis_static.lib %LibCopyDir%\%Target%\
  if exist %SrcDir%\libvorbisfiles_static.lib copy %SrcDir%\libvorbisfiles_static.lib %LibCopyDir%\%Target%\
) else (
  if exist %SrcDir%\libvorbis_rtdll.lib copy %SrcDir%\libvorbis_rtdll.lib %LibCopyDir%\%Target%\libvorbis_static.lib
  if exist %SrcDir%\libvorbis_rtdll.lib copy %SrcDir%\libvorbis_rtdll.lib %LibCopyDir%\%Target%\
  if exist %SrcDir%\libvorbis.lib copy %SrcDir%\libvorbis.lib %LibCopyDir%\%Target%\
  if exist %SrcDir%\libvorbis.dll copy %SrcDir%\libvorbis.dll %LibCopyDir%\%Target%\
  if exist %SrcDir%\libvorbis.pdb copy %SrcDir%\libvorbis.pdb %LibCopyDir%\%Target%\
)
:ENDIF_LibCopyDir

exit /b


:gen_rtdll
for /R %1 %%i in (*_static.sln *_static.vcxproj) do (
  call :gen_rtdll1 %%i
)
exit /b

:gen_rtdll1
set SrcFile=%1
set DstFile=%SrcFile:_static=_rtdll%
..\..\..\bld_lib_bat\tiny_replstr ++ MultiThreadedDLL MultiThreaded MultiThreadedDebugDLL MultiThreadedDebug MultiThreaded MultiThreadedDLL MultiThreadedDLLDebug MultiThreadedDebugDLL _static _rtdll -- %SrcFile% >%DstFile%
exit /b


:gen_static
for /R %1 %%i in (*_static.vcxproj) do (
  ..\..\..\bld_lib_bat\tiny_replstr -x ++ MultiThreadedDLL MultiThreaded MultiThreadedDebugDLL MultiThreadedDebug -- %%i
)
exit /b


:SlnCopyUpd
cd win32
mkdir %2
xcopy /S /I %1 %2
cd %2
devenv /Upgrade vorbis_dynamic.sln
call :DelBackup
devenv /Upgrade vorbis_static.sln
call :DelBackup
cd ..
cd ..
exit /b

:DelBackup
del UpgradeLog.htm
del /S /Q /F Backup\*.*
rmdir /S /Q Backup
exit /b
