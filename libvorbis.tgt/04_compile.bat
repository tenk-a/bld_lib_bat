rem @echo off
rem This batch-file license: boost software license version 1.0
rem libvorbis v1.3.6
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

rem set OggDir=
rem set OggVer=
set SrcOggVerVc8=1.1.4
set SrcOggVerVc9=1.1.4
set SrcOggVerVc10=1.2.0
set SrcOggVerVc10b=1.3.2

:ARG_LOOP
  if "%1"=="" goto ARG_LOOP_EXIT

  if /I "%1"=="static"   set HasRtSta=S
  if /I "%1"=="rtsta"    set HasRtSta=S
  if /I "%1"=="rtdll"    set HasRtDll=L

  if /I "%1"=="release"  set HasRel=r
  if /I "%1"=="debug"    set HasDbg=d

  if /I "%1"=="test"     set HasTest=1

  set ARG=%1
  if /I "%ARG:~0,7%"=="OggDir:"     set OggDir=%ARG:~7%

  shift
goto ARG_LOOP
:ARG_LOOP_EXIT

if "%StrPrefix%"=="" (
  if not "%VcVer%"=="" (
    if "%StrPrefix%"=="" set StrPrefix=%VcVer%_
  )
)

if "%Arch%"=="" set Arch=Win32
if "%Arch%"=="x86" set Arch=Win32

set SlnDir=
if "%VcVer%"=="vc142" set SlnDir=VS2019
if "%VcVer%"=="vc141" set SlnDir=VS2017
if "%VcVer%"=="vc140" set SlnDir=VS2015
if "%VcVer%"=="vc130" set SlnDir=VS2014
if "%VcVer%"=="vc120" set SlnDir=VS2013
if "%VcVer%"=="vc110" set SlnDir=VS2012
if "%VcVer%"=="vc100" set SlnDir=VS2010
if "%VcVer%"=="vc90"  set SlnDir=VS2008
if "%VcVer%"=="vc80"  set SlnDir=VS2005
if "%VcVer%"=="vc71"  set SlnDir=VS2003

if exist win32\%SlnDir% goto SKIP2
  if "%SlnDir%"=="VS2019" (
    rem call :SlnCopyUpd VS2010 VS2015
    rem call :SlnCopyUpd VS2015 VS2019
  )
  if "%SlnDir%"=="VS2017" (
    rem call :SlnCopyUpd VS2010 VS2015
    rem call :SlnCopyUpd VS2015 VS2019
  )
  if "%SlnDir%"=="VS2019" call :SlnCopyUpd VS2010 VS2019
  if "%SlnDir%"=="VS2017" call :SlnCopyUpd VS2010 VS2017
  if "%SlnDir%"=="VS2015" call :SlnCopyUpd VS2010 VS2015
  if "%SlnDir%"=="VS2014" call :SlnCopyUpd VS2010 VS2014
  if "%SlnDir%"=="VS2013" call :SlnCopyUpd VS2010 VS2013
  if "%SlnDir%"=="VS2012" call :SlnCopyUpd VS2010 VS2012
  if not exist win32\%SlnDir% (
     echo Not found 'win32\%SlnDir%' directory
     goto ERR
  )
:SKIP2

@rem if "%OggDir%"=="" (
@rem   for /f %%i in ('dir /b /on /ad ..\libogg*') do set OggDir=%%i
@rem )
@rem set OggVer=%OggDir:libogg-=%
@rem if "%OggVer%"=="%OggDir%" set OggVer=

if "%HasRtSta%%HasRtDll%"=="" (
  set HasRtSta=S
  set HasRtDll=L
)
if "%HasRel%%HasDbg%"=="" (
  set HasRel=r
  set HasDbg=d
)

if "%StrRtSta%%StrRtDll%"=="" set StrRtSta=_static

if "%HasRtDll%%HasRel%"=="Lr" call :Bld1 release rtdll
if "%HasRtDll%%HasDbg%"=="Ld" call :Bld1 debug   rtdll
if "%HasRtSta%%HasRel%"=="Sr" call :Bld1 release static
if "%HasRtSta%%HasDbg%"=="Sd" call :Bld1 debug   static

goto :END


:Bld1
set Conf=%1
set Rt=%2

rem set StrLibPath=
rem call %CcBatDir%\sub\StrLibPath.bat %CcTgtLibPathType% _ %VcVer% %Arch% %Rt% %Conf%
rem set Target=%StrLibPath%


pushd win32\%SlnDir%

if not "%OggVer%"=="" (
  if "%VcVer%"=="vc142" %TinyReplStr% -x ++ %SrcOggVerVc10% %OggVer% %SrcOggVerVc10b% %OggVer% VS2010 VS2019 VS2015 VS2019 -- libogg.props
  if "%VcVer%"=="vc141" %TinyReplStr% -x ++ %SrcOggVerVc10% %OggVer% %SrcOggVerVc10b% %OggVer% VS2010 VS2017 VS2015 VS2017 -- libogg.props
  if "%VcVer%"=="vc140" %TinyReplStr% -x ++ %SrcOggVerVc10% %OggVer% %SrcOggVerVc10b% %OggVer% VS2010 VS2015 -- libogg.props
  if "%VcVer%"=="vc130" %TinyReplStr% -x ++ %SrcOggVerVc10% %OggVer% %SrcOggVerVc10b% %OggVer% VS2010 VS2014 -- libogg.props
  if "%VcVer%"=="vc120" %TinyReplStr% -x ++ %SrcOggVerVc10% %OggVer% %SrcOggVerVc10b% %OggVer% VS2010 VS2013 -- libogg.props
  if "%VcVer%"=="vc110" %TinyReplStr% -x ++ %SrcOggVerVc10% %OggVer% %SrcOggVerVc10b% %OggVer% VS2010 VS2012 -- libogg.props
  if "%VcVer%"=="vc100" %TinyReplStr% -x ++ %SrcOggVerVc10% %OggVer% %SrcOggVerVc10b% %OggVer% -- libogg.props
  if "%VcVer%"=="vc90"  %TinyReplStr% -x ++ %SrcOggVerVc9%  %OggVer% -- libogg.props
  if "%VcVer%"=="vc80"  %TinyReplStr% -x ++ %SrcOggVerVc8%  %OggVer% -- libogg.props
)
call :DelIntDir
if %Rt%==static (
  call :gen_static
  msbuild vorbis_static.sln  /t:Build /p:Configuration=%Conf% /p:Platform=%Arch%
  if "%HasTest%"=="1" call :ExampleCompile %Rt%
) else (
  msbuild vorbis_dynamic.sln /t:Build /p:Configuration=%Conf% /p:Platform=%Arch%
  if "%HasTest%"=="1" call :ExampleCompile dll
  call :DelIntDir
  call :gen_rtdll
  msbuild vorbis_rtdll.sln   /t:Build /p:Configuration=%Conf% /p:Platform=%Arch%
  if "%HasTest%"=="1" call :ExampleCompile %Rt%
)
call :DelIntDir
popd

exit /b


:gen_rtdll
for /R %1 %%i in (*_static.sln *_static.vcxproj) do (
  call :gen_rtdll1 %%i
)
exit /b

:gen_rtdll1
set SrcFile=%1
set DstFile=%SrcFile:_static=_rtdll%
%TinyReplStr% ++ MultiThreadedDLL MultiThreaded MultiThreadedDebugDLL MultiThreadedDebug MultiThreaded MultiThreadedDLL MultiThreadedDLLDebug MultiThreadedDebugDLL _static _rtdll -- %SrcFile% >%DstFile%
exit /b


:gen_static
for /R %1 %%i in (*_static.vcxproj) do (
  %TinyReplStr% -x ++ MultiThreadedDLL MultiThreaded MultiThreadedDebugDLL MultiThreadedDebug -- %%i
)
exit /b


:DelIntDir
del /S /Q *.obj *.tlog *.lastbuildstate *.log *.bak
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


:ExampleCompile
set RtStr=_%1
if "%RtStr%"=="_dll" "set RtStr="
set MtStr=-MD
if "%Conf%"=="debug" set MtStr=%MtStr%d
if not exist %Arch%\%Conf%\examples mkdir %Arch%\%Conf%\examples
pushd %Arch%\%Conf%\examples
  set RelRoot=..\..\..\..\..
  set EXAMPLE_OPTS=%MtStr% -I%RelRoot%\include -I%RelRoot%\..\%OggDir%\include
  set EXAMPLE_LIBS=-link-libpath:%RelRoot%\..\%OggDir%\win32\%SlnDir%\%Arch%\%Conf% libogg%RtStr%.lib ..\libvorbis%RtStr%.lib ..\libvorbisfile%RtStr%.lib
  cl %EXAMPLE_OPTS% -Fechaining_example%RtStr%.exe %RelRoot%\examples\chaining_example.c %EXAMPLE_LIBS%
  cl %EXAMPLE_OPTS% -Fedecoder_example%RtStr%.exe %RelRoot%\examples\decoder_example.c %EXAMPLE_LIBS%
  cl %EXAMPLE_OPTS% -Feencoder_example%RtStr%.exe %RelRoot%\examples\encoder_example.c %EXAMPLE_LIBS%
  cl %EXAMPLE_OPTS% -Doff_t=__int64 -Feseeking_example%RtStr%.exe %RelRoot%\examples\seeking_example.c %EXAMPLE_LIBS%
  cl %EXAMPLE_OPTS% -Fevorbisfile_example%RtStr%.exe %RelRoot%\examples\vorbisfile_example.c %EXAMPLE_LIBS%
  cl %EXAMPLE_OPTS% -D_USE_MATH_DEFINES -Dsnprintf=_snprintf -Fetest%RtStr%.exe %RelRoot%\test\test.c %RelRoot%\test\util.c %RelRoot%\test\write_read.c %EXAMPLE_LIBS%
popd
exit /b

:ERR
endlocal
exit /b 1

:END
endlocal
