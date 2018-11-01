@echo off
rem This batch-file license: boost software license version 1.0
setlocal
call libs_config.bat

set TgtName=libjpeg-turbo
set TgtDir=
set SrcIncSubDir=
set SrcLibSubDir=%CcLibDir%
set DstIncSubDir=
set DstLibSubDir=
set hdr1=jpeglib.h
set hdr2=jconfig.h
set hdr3=jmorecfg.h
set hdr4=jpegint.h
set hdr5=jerror.h
set hdr6=turbojpeg.h
set hdr7=
set hdr8=
set hdr9=
set Arg=%CcBld1Arg%

pushd ..

set VcVer=
:ARG_LOOP
  if "%1"=="" goto ARG_LOOP_EXIT

  if not "%VcVer%"=="" goto VCVAR_SKIP
  if /I "%1"=="vc71"     set VcVer=vc71
  if /I "%1"=="vc80"     set VcVer=vc80
  if /I "%1"=="vc90"     set VcVer=vc90
  if /I "%1"=="vc100"    set VcVer=vc100
  if /I "%1"=="vc110"    set VcVer=vc110
  if /I "%1"=="vc120"    set VcVer=vc120
  if /I "%1"=="vc130"    set VcVer=vc130
  if /I "%1"=="vc140"    set VcVer=vc140
  if /I "%1"=="vc141"    set VcVer=vc141
  goto ARG_NEXT
:VCVAR_SKIP
  if "%TgtDir%"==""      set TgtDir=%1
:ARG_NEXT
  shift
goto ARG_LOOP
:ARG_LOOP_EXIT

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

set Arg=%Arg% LibPrefix:%LibPrefix% LibDir:%SrcLibSubDir%
set Arg=%Arg% LibRel:%CcLibStrRelease% LibDbg:%CcLibStrDebug% LibRtSta:%CcLibStrStatic% LibRtDll:%CcLibStrRtDll%
if "%CcNoRtStatic%"=="1" set Arg=%Arg% rtdll

rem goto BUILD_SKIP
pushd %TgtDir%
if "%CcHasX86%"=="1" (
  call ..\bld_lib_bat\setcc.bat %VcVer% Win32
  call ..\bld_lib_bat\bld1_%TgtName%.bat %VcVer% Win32 %Arg%
)
if "%CcHasX64%"=="1" (
  call ..\bld_lib_bat\setcc.bat %VcVer% x64
  call ..\bld_lib_bat\bld1_%TgtName%.bat %VcVer% x64 %Arg%
)
popd
:BUILD_SKIP

if not exist %CcLibsVcIncDir% mkdir %CcLibsVcIncDir%
if not exist %CcLibsVcLibDir% mkdir %CcLibsVcLibDir%

if "%LibPrefix%"=="" set LibPrefix=vc_

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

goto END


:LibCopy
set Prefix=%1
set Arch=%2
set Rt=%3
set Conf=%4
set SubDir=%5
if "%Rt%"=="rtsta" set Rt=%CcLibStrStatic%
if "%Rt%"=="rtdll" set Rt=%CcLibStrRtDll%
if "%Conf%"=="rel" set Conf=%CcLibStrRelease%
if "%Conf%"=="dbg" set Conf=%CcLibStrDebug%

set LibDir1=%Prefix%%Arch%%Rt%%Conf%

set SrcLibDir=%TgtDir%\%SrcLibSubDir%\%LibDir1%
if not exist %SrcLibDir% exit /b

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
