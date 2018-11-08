@echo off
rem This batch-file license: boost software license version 1.0
setlocal

set TgtName=libogg
set TgtDir=
set SrcIncSubDir=include\ogg
set SrcLibSubDir=
set DstIncSubDir=ogg
set DstLibSubDir=
set hdr1=ogg.h
set hdr2=os_types.h
set hdr3=
set hdr4=
set hdr5=
set hdr6=
set hdr7=
set hdr8=
set hdr9=
set Arg=
set NeedTinyReplStr=1


call libs_config.bat
pushd ..

set HasX86=
set HasX64=
set HasRel=
set HasDbg=
set HasRtSta=
set HasRtDll=
set HasTest=
set NoCopy=
set NoBuild=
set VcVer=
set Arg=%Arg% %CcBld1Arg%
if "%SrcLibSubDir%"=="" set "SrcLibSubDir=%CcLibDir%"

:ARG_LOOP
  if "%1"=="" goto ARG_LOOP_EXIT

  if /I "%1"=="x86"      set HasX86=1
  if /I "%1"=="Win32"    set HasX86=1
  if /I "%1"=="x64"      set HasX64=1

  if /I "%1"=="static"   set HasRtSta=static
  if /I "%1"=="rtsta"    set HasRtSta=static
  if /I "%1"=="rtdll"    set HasRtDll=rtdll

  if /I "%1"=="release"  set HasRel=release
  if /I "%1"=="debug"    set HasDbg=debug

  if /I "%1"=="test"     set HasTest=test

  if /I "%1"=="vc71"     set VcVer=vc71
  if /I "%1"=="vc80"     set VcVer=vc80
  if /I "%1"=="vc90"     set VcVer=vc90
  if /I "%1"=="vc100"    set VcVer=vc100
  if /I "%1"=="vc110"    set VcVer=vc110
  if /I "%1"=="vc120"    set VcVer=vc120
  if /I "%1"=="vc130"    set VcVer=vc130
  if /I "%1"=="vc140"    set VcVer=vc140
  if /I "%1"=="vc141"    set VcVer=vc141

  if /I "%1"=="NoCopy"   set NoCopy=1
  if /I "%1"=="NoBuild"  set NoBuild=1
  set A=%1
  if /I "%A:~0,4%"=="src:" set TgtDir=%A:~4%

  shift
goto ARG_LOOP
:ARG_LOOP_EXIT
set A=

if "%HasX86%%HasX64%"=="" (
  set HasX86=%CcHasX86%
  set HasX64=%CcHasX64%
)

set LibPrefix=%VcVer%_
if "%VcVer%"=="" (
  set VcVer=%CcName%
  set LibPrefix=%CcLibPrefix%
)

if "%TgtDir%"=="" (
  for /f %%i in ('dir /b /on /ad %TgtName%*') do set TgtDir=%%i
)

if "%TgtDir%"=="" (
  echo ERROR: not found source directory
  goto END
)
if not exist "%TgtDir%" (
  echo ERROR: not found source directory
  goto END
)

set Arg=%Arg% %HasRtSta% %HasRtDll% %HasRel% %HasDbg% %HasTest%
set Arg=%Arg% LibPrefix:%LibPrefix% LibDir:%SrcLibSubDir%
set Arg=%Arg% LibRel:%CcLibStrRelease% LibDbg:%CcLibStrDebug% LibRtSta:%CcLibStrStatic% LibRtDll:%CcLibStrRtDll%
if "%CcNoRtStatic%"=="1" set Arg=%Arg% rtdll

rem goto BUILD_SKIP
pushd %TgtDir%
if "%HasX86%"=="1" (
  call ..\bld_lib_bat\setcc.bat %VcVer% Win32
  call ..\bld_lib_bat\bld1_%TgtName%.bat %VcVer% Win32 %Arg%
)
if "%HasX64%"=="1" (
  call ..\bld_lib_bat\setcc.bat %VcVer% x64
  call ..\bld_lib_bat\bld1_%TgtName%.bat %VcVer% x64 %Arg%
)
popd
:BUILD_SKIP

if "%NoCopy%"=="1" goto COPY_SKIP
if not exist %CcLibsVcIncDir% mkdir %CcLibsVcIncDir%
if not exist %CcLibsVcLibDir% mkdir %CcLibsVcLibDir%

if "%LibPrefix%"=="" set LibPrefix=vc_

call :HdrCopy

call :LibCopy %LibPrefix% Win32 rtsta rel %DstLibSubDir%
call :LibCopy %LibPrefix% Win32 rtsta dbg %DstLibSubDir%
call :LibCopy %LibPrefix% Win32 rtdll rel %DstLibSubDir%
call :LibCopy %LibPrefix% Win32 rtdll dbg %DstLibSubDir%
if "%CcHasX64%"=="1" (
  call :LibCopy %LibPrefix% x64 rtsta rel %DstLibSubDir%
  call :LibCopy %LibPrefix% x64 rtsta dbg %DstLibSubDir%
  call :LibCopy %LibPrefix% x64 rtdll rel %DstLibSubDir%
  call :LibCopy %LibPrefix% x64 rtdll dbg %DstLibSubDir%
)
:COPY_SKIP

goto END


:HdrCopy
set SrcIncDir=%TgtDir%
if not "%SrcIncSubDir%"=="" (
  set SrcIncDir=%SrcIncDir%\%SrcIncSubDir%
)
set DstIncDir=%CcLibsVcIncDir%
if not exist "%DstIncDir%" mkdir "%DstIncDir%"
if "%DstIncSubDir%"=="" goto SKIP2
  set DstIncDir=%DstIncDir%\%DstIncSubDir%
  if not exist "%DstIncDir%" mkdir "%DstIncDir%"
  if exist     "%DstIncDir%" del /q "%DstIncDir%\*.*"
:SKIP2
if not "%hdr1%"=="" copy %SrcIncDir%\%hdr1% %DstIncDir%\
if not "%hdr2%"=="" copy %SrcIncDir%\%hdr2% %DstIncDir%\
if not "%hdr3%"=="" copy %SrcIncDir%\%hdr3% %DstIncDir%\
if not "%hdr4%"=="" copy %SrcIncDir%\%hdr4% %DstIncDir%\
if not "%hdr5%"=="" copy %SrcIncDir%\%hdr5% %DstIncDir%\
if not "%hdr6%"=="" copy %SrcIncDir%\%hdr6% %DstIncDir%\
if not "%hdr7%"=="" copy %SrcIncDir%\%hdr7% %DstIncDir%\
if not "%hdr8%"=="" copy %SrcIncDir%\%hdr8% %DstIncDir%\
if not "%hdr9%"=="" copy %SrcIncDir%\%hdr9% %DstIncDir%\
exit /b


:LibCopy
set Prefix=%1
set Arch=%2
set Rt=%3
set Conf=%4
set SubDir=%5
set SrcConf=
if "%Conf%"=="rel" set SrcConf=release
if "%Conf%"=="dbg" set SrcConf=debug

if "%Rt%"=="rtsta" set Rt=%CcLibStrStatic%
if "%Rt%"=="rtdll" set Rt=%CcLibStrRtDll%
if "%Conf%"=="rel" set Conf=%CcLibStrRelease%
if "%Conf%"=="dbg" set Conf=%CcLibStrDebug%

set SlnDir=
if "%VcVer%"=="vc141" set SlnDir=VS2017
if "%VcVer%"=="vc140" set SlnDir=VS2015
if "%VcVer%"=="vc130" set SlnDir=VS2014
if "%VcVer%"=="vc120" set SlnDir=VS2013
if "%VcVer%"=="vc110" set SlnDir=VS2012
if "%VcVer%"=="vc100" set SlnDir=VS2010
if "%VcVer%"=="vc90"  set SlnDir=VS2008
if "%VcVer%"=="vc80"  set SlnDir=VS2005
if "%VcVer%"=="vc71"  set SlnDir=VS2003

set SrcLibDir=%TgtDir%\win32\%SlnDir%\%Arch%\%SrcConf%
if not exist %SrcLibDir% exit /b

set LibDir1=%Prefix%%Arch%%Rt%%Conf%
set DstLibDir=%CcLibsVcLibDir%\%LibDir1%
if not exist %DstLibDir% mkdir %DstLibDir%
if not "%SubDir%"=="" (
  set DstLibDir=%DstLibDir%\%SubDir%
  if not exist %DstLibDir% mkdir %DstLibDir%
)

if exist %SrcLibDir%\*.lib copy /b %SrcLibDir%\*.lib %DstLibDir%\
if exist %SrcLibDir%\*.dll copy /b %SrcLibDir%\*.dll %DstLibDir%\
if exist %SrcLibDir%\*.pdb copy /b %SrcLibDir%\*.pdb %DstLibDir%\

exit /b


:END
popd
endlocal
