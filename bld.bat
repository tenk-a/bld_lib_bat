@rem bld.bat
@rem author Masahi Kitamura
@rem This batch-file license: boost software license version 1.0
@setlocal
@set echo_flag=on
@if %echo_flag%==off @echo %echo_flag%
pushd %~dp0
goto BEGIN

:ERR
@echo bld [TARGET] [sub:STR] [VC] [...]
@echo TARGET = Target library name. (Use TARGET.tgt)
@echo sub:STR= Use TARGET.tgt/STR settings.
@echo VC     = vc80(2005) vc90(2008) vc100(2010) vc110(2011)
@echo          vc120(2013) vc140(2015) vc141(2017) vc142(2019)
@echo Win32  = Windows x86
@echo x64    = Windows x64
@echo static = Static C/C++ runtime.
@echo rtdll  = Dynamic(dll) C/C++ runtime.
@echo debug  = DEBUG Build.
@echo release= RELEASE build.
@echo test   = Build test(example,sample) program.
@echo .
@echo * No Win32  and x64     ... Set Win32  and x64
@echo * No static and rtdll   ... Set static and rtdll
@echo * No debug  and release ... Set debug  and release
goto END


:BEGIN
set CcBatDir=%CD%
set CcLibsRoot=
set CcTgtLibPathType=J_VA
set CcTgtLibDir=lib
set CcTgtBldDir=build
set CcInstallPathType=D_VA
set CcInstallIncDir=..\include
set CcInstallLibDir=..\lib
set CcInstallDllDir=..\dll
set CcStrRtDll=
set CcStrStatic=_static
set CcStrDll=_dll

call bld_config.bat

if "%CcLibsRoot%"=="" set CcLibsRoot=..
pushd %CcLibsRoot%
set CcLibsRoot=%CD%
popd

if exist bld_custom.bat call bld_custom.bat

if "%CcLibsRoot%"=="" set CcLibsRoot=..
pushd %CcLibsRoot%
set CcLibsRoot=%CD%
popd

if "%1"=="" goto ERR
set TgtCnf=%1
set TgtCnf=%TgtCnf:.tgt=%
set TgtCnfDir=%CcBatDir%\%TgtCnf%.tgt
if not exist %TgtCnfDir% goto ERR

shift

set TgtName=
set TgtDir=
set TgtVer=
set GitUrl=
set GitSubmodule=
set GitBranch=
set GitTag=
set ZipUrl=
set ZipDir=
set SrcIncSubDir=
set InstallIncSubDir=
set InstallLibSubDir=
set HdrIsDir=
set hdr1=
set hdr2=
set hdr3=
set hdr4=
set hdr5=
set hdr6=
set hdr7=
set hdr8=
set hdr9=
set Arg=
set AddArg=
set NoBuild=
set Install=1
set NoInstall=
set force=
set Required1=
set Required2=
set Required3=
set Required4=
set Required5=
set Required6=
set Required7=
set Required8=
set Required9=
set Required1Dir=
set Required2Dir=
set Required3Dir=
set Required4Dir=
set Required5Dir=
set Required6Dir=
set Required7Dir=
set Required8Dir=
set Required9Dir=

set VcVer=
set Arch=
set FlagX86=
set FlagX64=
set HasRel=
set HasDbg=
set HasRtSta=
set HasRtDll=
set HasDll=
set HasTest=
set HasClean=
set LibRtSta=%CcStrStatic%
set LibRtDll=%CcStrRtDll%
set LibRel=%CcStrRelease%
set LibDbg=%CcStrDebug%

set A=%1
if "%A%"=="" goto ERR
if /I not "%A:~0,4%"=="sub:" goto SKIP1
  set TgtCnfDir=%TgtCnfDir%\%A:~4%
  shift
:SKIP1

if not exist %CcInstallIncDir% goto SKIP_1b
 pushd %CcInstallIncDir%
 set CcInstallIncDir=%CD%
 popd
:SKIP_1b
pause
if not exist %CcInstallLibDir% goto SKIP_1c
  pushd %CcInstallLibDir%
  set CcInstallLibDir=%CD%
  popd
:SKIP_1c
if not exist %CcInstallDllDir% goto SKIP_1c
  pushd %CcInstallDllDir%
  set CcInstallDllDir=%CD%
  popd
:SKIP_1c

call %TgtCnfDir%\01_init.bat

if "%TgtName%"=="" set TgtName=%TgtConf%
if "%TgtDir%"=="" set TgtDir=%TgtName%

set Arg=%Arg% %CcBld1Arg%

:ARG_LOOP
  set A=%1

  if "%1"=="" goto ARG_LOOP_EXIT

  if /I "%1"=="x86"      set FlagX86=Win32
  if /I "%1"=="Win32"    set FlagX86=Win32
  if /I "%1"=="x64"      set FlagX64=x64
  if /I "%1"=="Win64"    set FlagX64=x64

  if /I "%1"=="static"   set HasRtSta=static
  if /I "%1"=="rtsta"    set HasRtSta=static
  if /I "%1"=="rtdll"    set HasRtDll=rtdll
  if /I "%1"=="dll"      set HasDll=dll

  if /I "%1"=="release"  set HasRel=release
  if /I "%1"=="debug"    set HasDbg=debug

  if /I "%1"=="clean"    set HasClean=clean
  if /I "%1"=="test"     set HasTest=test
  if /I "%1"=="exsample" set HasTest=test

  if /I "%1"=="vc71"     set VcVer=vc71
  if /I "%1"=="vc80"     set VcVer=vc80
  if /I "%1"=="vc90"     set VcVer=vc90
  if /I "%1"=="vc100"    set VcVer=vc100
  if /I "%1"=="vc110"    set VcVer=vc110
  if /I "%1"=="vc120"    set VcVer=vc120
  if /I "%1"=="vc140"    set VcVer=vc140
  if /I "%1"=="vc141"    set VcVer=vc141
  if /I "%1"=="vc142"    set VcVer=vc142

  if /I "%1"=="vc2003"   set VcVer=vc71
  if /I "%1"=="vc2005"   set VcVer=vc80
  if /I "%1"=="vc2008"   set VcVer=vc90
  if /I "%1"=="vc2010"   set VcVer=vc100
  if /I "%1"=="vc2012"   set VcVer=vc110
  if /I "%1"=="vc2013"   set VcVer=vc120
  if /I "%1"=="vc2015"   set VcVer=vc140
  if /I "%1"=="vc2017"   set VcVer=vc141
  if /I "%1"=="vc2019"   set VcVer=vc142

  if /I "%1"=="force"    set force=1
  if /I "%1"=="DL"       set DL_only=1
  if /I "%1"=="donwload" set DL_only=1
  if /I "%1"=="Build"    set NoBuild=
  if /I "%1"=="NoBuild"  set NoBuild=1
  if /I "%1"=="Install"  set Install=1
  if /I "%1"=="NoInstall" set Install=
  if /I "%1"=="InstallOnly" (
    set NoBuild=1
    set Install=
  )
  if /I "%1"=="NoInstallSubDir" (
    set InstallIncSubDir=
    set InstallLibSubDir=
  )

  if /I "%A:~0,4%"=="tgt:" set TgtDir=%A:~4%
  if /I "%A:~0,4%"=="sub:" set ConfSubDir=%A:~4%
  if /I "%A:~0,9%"=="libsroot:" set CcLibsRoot=%A:~9%
  if /I "%A:~0,7%"=="IncDir:" set CcInstallIncDir=%A:~7%
  if /I "%A:~0,7%"=="LibDir:" set CcInstallLibDir=%A:~7%
  if /I "%A:~0,7%"=="DllDir:" set CcInstallDllDir=%A:~7%

  if exist %TgtCnfDir%\03_arg.bat call %TgtCnfDir%\03_arg.bat %1

  shift
goto ARG_LOOP
:ARG_LOOP_EXIT
set A=

pushd %CcLibsRoot%
set CcLibsRoot=%CD%
popd

if not exist %CcInstallIncDir% goto SKIP_20
 pushd %CcInstallIncDir%
 set CcInstallIncDir=%CD%
 popd
:SKIP_20

if not exist %CcInstallLibDir% goto SKIP_30
  pushd %CcInstallLibDir%
  set CcInstallLibDir=%CD%
  popd
:SKIP_30

if not exist %CcInstallDllDir% goto SKIP_40
  pushd %CcInstallDllDir%
  set CcInstallDllDir=%CD%
  popd
:SKIP_40

if "%TgtDir%"=="" (
  echo ERROR: Not found target library directory.
  goto END
)

if not "%Required1%"=="" call :Required %Required1% %Required1Dir%
if not "%Required2%"=="" call :Required %Required2% %Required2Dir%
if not "%Required3%"=="" call :Required %Required3% %Required3Dir%
if not "%Required4%"=="" call :Required %Required4% %Required4Dir%
if not "%Required5%"=="" call :Required %Required5% %Required5Dir%
if not "%Required6%"=="" call :Required %Required6% %Required6Dir%
if not "%Required7%"=="" call :Required %Required7% %Required7Dir%
if not "%Required8%"=="" call :Required %Required8% %Required8Dir%
if not "%Required9%"=="" call :Required %Required9% %Required9Dir%

if "%DL_only%%force%"=="11" call :Download
if not exist %CcLibsRoot%\%TgtDir% call :Download
if "%DL_only%"=="1" goto END

if not exist "%CcLibsRoot%\%TgtDir%" (
  echo ERROR: Not found target library directory.
  goto END
)

set FoundCompiler=
if not "%VcVer%"=="" goto SKIP_VC_VER
  if /I not "%PATH:Microsoft Visual Studio .NET 2003=%"=="%PATH%" set VcVer=vc71
  if /I not "%PATH:Microsoft Visual Studio 8=%"=="%PATH%"    set VcVer=vc80
  if /I not "%PATH:Microsoft Visual Studio 9.0=%"=="%PATH%"  set VcVer=vc90
  if /I not "%PATH:Microsoft Visual Studio 10.0=%"=="%PATH%" set VcVer=vc100
  if /I not "%PATH:Microsoft Visual Studio 11.0=%"=="%PATH%" set VcVer=vc110
  if /I not "%PATH:Microsoft Visual Studio 12.0=%"=="%PATH%" set VcVer=vc120
  if /I not "%PATH:Microsoft Visual Studio 13.0=%"=="%PATH%" set VcVer=vc130
  if /I not "%PATH:Microsoft Visual Studio 14.0=%"=="%PATH%" set VcVer=vc140
  if /I not "%PATH:Microsoft Visual Studio\2017=%"=="%PATH%" set VcVer=vc141
  if /I not "%PATH:Microsoft Visual Studio\2019=%"=="%PATH%" set VcVer=vc142
  if not "%VcVer%"=="" set FoundCompiler=Found
  if /I not "%FoundCompiler%%FlagX86%%FlagX64%"=="Found" goto ARCH_SKIP1
    if "%VcVer%"=="vc142"    if /I not "%PATH:\bin\HostX64\x64=%"=="%PATH%" set FlagX64=x64
    if "%VcVer%"=="vc141"    if /I not "%PATH:\bin\HostX64\x64=%"=="%PATH%" set FlagX64=x64
    if /I not "%PATH:Microsoft Visual Studio 14.0\VC\BIN\amd64=%"=="%PATH%" set FlagX64=x64
    if /I not "%PATH:Microsoft Visual Studio 13.0\VC\BIN\amd64=%"=="%PATH%" set FlagX64=x64
    if /I not "%PATH:Microsoft Visual Studio 12.0\VC\BIN\amd64=%"=="%PATH%" set FlagX64=x64
    if /I not "%PATH:Microsoft Visual Studio 11.0\VC\BIN\amd64=%"=="%PATH%" set FlagX64=x64
    if /I not "%PATH:Microsoft Visual Studio 10.0\VC\BIN\amd64=%"=="%PATH%" set FlagX64=x64
    if /I not "%PATH:Microsoft Visual Studio 9.0\VC\BIN\amd64=%"=="%PATH%"  set FlagX64=x64
    if /I not "%PATH:Microsoft Visual Studio 8\VC\BIN\amd64=%"=="%PATH%"    set FlagX64=x64
    if "%FlagX64%"=="" set FlagX86=Win32
    set FoundCompiler=%FlagX64%%FlagX86%
    goto ARCH_SKIP2
  :ARCH_SKIP1
    set FoundCompiler=
  :ARCH_SKIP2
:SKIP_VC_VER
if "%VcVer%"=="" (
  goto ERR
)

set LibPrefix=%VcVer%_

if "%FlagX86%%FlagX64%"=="" (
  set FlagX86=Win32
  set FlagX64=x64
)

set CurArch=%FoundCompiler%
if "%CurArch%"=="" set CurArch=%FlagX64%
if "%CurArch%"=="" set CurArch=Win32

rem make replace tool
set TinyReplStr=%CcBatDir%\sub\tiny_replstr.exe
if "%NeedTinyReplStr%"=="" goto TinyReplStr_SKIP
if exist %TinyReplStr% goto TinyReplStr_SKIP
call :SetCompiler %VcVer% %CurArch%
pushd %CcBatDir%\sub
call %CcBatDir%\sub\gen_replstr.bat
popd
:TinyReplStr_SKIP

set Arg=%Arg% %HasRtSta% %HasRtDll% %HasDll% %HasRel% %HasDbg% %HasTest% %HasClean%
set Arg=%Arg% LibPrefix:%LibPrefix% LibDir:%CcTgtLibDir%
set Arg=%Arg% LibRel:%LibRel% LibDbg:%LibDbg% LibRtSta:%LibRtSta% LibRtDll:%LibRtDll%
set Arg=%Arg% %AddArg%

if "%NoBuild%"==""  call :Build
if "%Install%"=="1" call :InstallCopy

goto END

rem
rem
:Required
set ReqTgt=%1
set ReqDir=%2
if "%ReqDir%"=="" set ReqDir=%ReqTgt%
if not exist %ReqTgt%.tgt goto Required_ERR
if exist %CcLibsRoot%\%ReqDir% exit /b
rem call Bld.bat %ReqTgt% %VcVer% %FlagX64% %FlagX86% %HasRtSta% %HasRtDll% %HasDll% %HasRel% %HasDbg%
call Bld.bat %ReqTgt% %VcVer% %FlagX64% %FlagX86% %HasRtSta% %HasRtDll% %HasDll% %HasRel% %HasDbg%
exit /b %ERRORLEVEL%

:Required_ERR
@echo [ERROR] %TgtConf%: no %ReqTgt%.tgt
exit 1
goto END

rem
rem
:Download
if not exist %TgtCnfDir%\02_download.bat goto DL_SKIP1
call %TgtCnfDir%\02_download.bat
exit /b

:DL_SKIP1
if "%GitUrl%"=="" goto DL_SKIP2
set GitOpt=
if not "%GitBranch%"=="" (
  set GitOpt=%GitOpt% -b %GitBranch%
)
if not "%GitSubmodule%"=="" (
  set GitOpt=%GitOpt% --recursive
)
git clone %GitOpt% %GitUrl% %CcLibsRoot%/%TgtDir%

@rem if "%GitBranch%"=="" (
@rem   git clone %GitUrl% %CcLibsRoot%/%TgtDir%
@rem ) else (
@rem   git clone -b %GitBranch% %GitUrl% %CcLibsRoot%/%TgtDir%
@rem )
@rem if not "%GitSubmodule%"=="1" goto DL_SKIP1b
@rem   pushd %CcLibsRoot%/%TgtDir%
@rem   git submodule update -i
@rem   popd
@rem :DL_SKIP1b

if not "%GitTag%"=="" (
   git checkout -b %GitTag% refs/tags/%GitTag%
)

exit /b

:DL_SKIP2
if "%ZipUrl%"=="" goto DL_SKIP3
call %CcBatDir%\sub\dl_zip.bat %ZipUrl% %ZipDir% %TgtDir%
exit /b

:DL_SKIP3
exit /b

rem
rem
:Build
pushd %CcLibsRoot%\%TgtDir%
if not "%FlagX64%"=="x64" goto BUILD_SKIP64
  call :SetCompiler %VcVer% x64
  call %TgtCnfDir%\04_compile.bat %VcVer% x64 %Arg%
  if not ERRORLEVEL 0 set NoInstall=1
:BUILD_SKIP64
if not "%FlagX86%"=="Win32" goto BUILD_SKIP32
  call :SetCompiler %VcVer% Win32
  call %TgtCnfDir%\04_compile.bat %VcVer% Win32 %Arg%
  if not ERRORLEVEL 0 set NoInstall=1
:BUILD_SKIP32
popd
exit /b

:SetCompiler
if "%FoundCompiler%"=="%2" exit /b
call setcc.bat %1 %2
if not %echo_flag%==off @echo on
exit /b


rem
rem
:InstallCopy
if "%NoInstall%"=="1" exit /b
if not exist %CcInstallIncDir% mkdir %CcInstallIncDir%
pushd %CcInstallIncDir%
set CcInstallIncDir=%CD%
popd

if not exist %CcInstallLibDir% mkdir %CcInstallLibDir%
pushd %CcInstallLibDir%
set CcInstallLibDir=%CD%
popd

set TgtFullDir=%CcLibsRoot%\%TgtDir%
pushd %TgtFullDir%
if not exist %TgtCnfDir%\05_install.bat goto SKIP_INSTALL_COPY1
  set A_FlagX86=%FlagX86%
  set A_FlagX64=%FlagX64%
  if "%A_FlagX86%"=="" set A_FlagX86=-
  if "%A_FlagX64%"=="" set A_FlagX64=-
  call %TgtCnfDir%\05_install.bat %TgtFullDir% %VcVer% %A_FlagX86% %A_FlagX64%
  goto SKIP_INSTALL_COPY2
:SKIP_INSTALL_COPY1
  call :HdrCopy
  if "%FlagX64%"=="x64" (
    call :LibCopy x64 static release
    call :LibCopy x64 static debug
    call :LibCopy x64 rtdll  release
    call :LibCopy x64 rtdll  debug
    call :LibCopy x64 dll    release
    call :LibCopy x64 dll    debug
  )
  if "%FlagX86%"=="Win32" (
    call :LibCopy Win32 static release
    call :LibCopy Win32 static debug
    call :LibCopy Win32 rtdll  release
    call :LibCopy Win32 rtdll  debug
    call :LibCopy Win32 dll    release
    call :LibCopy Win32 dll    debug
  )
:SKIP_INSTALL_COPY2
popd
exit/b

:HdrCopy
set SrcIncDir=%TgtFullDir%
if not "%SrcIncSubDir%"=="" (
  set SrcIncDir=%SrcIncDir%\%SrcIncSubDir%
)
set DstIncDir=%CcInstallIncDir%
if "%InstallIncSubDir%"=="" goto HdrCpy_SKIP1
  set DstIncDir=%DstIncDir%\%InstallIncSubDir%
  if exist "%DstIncDir%" rmdir /s /q "%DstIncDir%"
:HdrCpy_SKIP1
if not exist "%DstIncDir%" mkdir "%DstIncDir%"
if not "%hdr1%"=="*" goto HdrCpy_SKIP2
  xcopy %SrcIncDir% %DstIncDir% /R /Y /I /K /E
  exit /b
:HdrCpy_SKIP2
if "%HdrIsDir%"=="" goto HdrCpy_SKIP3
  if not "%hdr1%"=="" xcopy %SrcIncDir%\%hdr1% %DstIncDir%\%hdr1% /R /Y /I /K /E
  if not "%hdr2%"=="" xcopy %SrcIncDir%\%hdr2% %DstIncDir%\%hdr2% /R /Y /I /K /E
  if not "%hdr3%"=="" xcopy %SrcIncDir%\%hdr3% %DstIncDir%\%hdr3% /R /Y /I /K /E
  if not "%hdr4%"=="" xcopy %SrcIncDir%\%hdr4% %DstIncDir%\%hdr4% /R /Y /I /K /E
  if not "%hdr5%"=="" xcopy %SrcIncDir%\%hdr5% %DstIncDir%\%hdr5% /R /Y /I /K /E
  if not "%hdr6%"=="" xcopy %SrcIncDir%\%hdr6% %DstIncDir%\%hdr6% /R /Y /I /K /E
  if not "%hdr7%"=="" xcopy %SrcIncDir%\%hdr7% %DstIncDir%\%hdr7% /R /Y /I /K /E
  if not "%hdr8%"=="" xcopy %SrcIncDir%\%hdr8% %DstIncDir%\%hdr8% /R /Y /I /K /E
  if not "%hdr9%"=="" xcopy %SrcIncDir%\%hdr9% %DstIncDir%\%hdr9% /R /Y /I /K /E
exit /b
:HdrCpy_SKIP3
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
set Arch=%1
set Rt=%2
set Conf=%3

set StrLibPath=
call %CcBatDir%\sub\StrLibPath.bat %CcTgtLibPathType% %TgtFullDir%\%CcTgtLibDir% %VcVer% %Arch% %Rt% %Conf%
set SrcLibDir=%StrLibPath%
if not exist %SrcLibDir% exit /b

set StrLibPath=
call %CcBatDir%\sub\StrLibPath.bat %CcInstallPathType% %CcInstallLibDir% %VcVer% %Arch% %Rt% %Conf%
set DstLibDir=%StrLibPath%
if not "%DstLibDir%"=="" goto LibCopy_SKIP1
  echo [ERROR] No %%CcInstallPathType%% [CcInstallPathType=%CcInstallPathType% VcVer=%VcVer% Arch=%Arch% Rt=%Rt% Conf=%Conf%]
  pause
  exit /b
:LibCopy_SKIP1
if not "%InstallLibSubDir%"=="" set DstLibDir=%DstLibDir%\%InstallLibSubDir%
if not exist %DstLibDir% mkdir %DstLibDir%

if exist %SrcLibDir%\*.lib copy /b %SrcLibDir%\*.lib %DstLibDir%\
rem if exist %SrcLibDir%\*.dll copy /b %SrcLibDir%\*.dll %DstLibDir%\
rem if exist %SrcLibDir%\*.pdb copy /b %SrcLibDir%\*.pdb %DstLibDir%\

rem for dll
if not exist %SrcLibDir%\*.dll exit /b
set StrLibPath=
call %CcBatDir%\sub\StrLibPath.bat %CcInstallPathType% %CcInstallDllDir% %VcVer% %Arch% %Rt% %Conf%
set DstDllDir=%StrLibPath%
if "%DstDllDir%"=="" (
  echo [ERROR] No %%CcInstallPathType%% {CcInstallPathType=%CcInstallPathType% VcVer=%VcVer% Arch=%Arch% Rt=%Rt% Conf=%Conf%}
  exit /b
)
if not "%InstallLibSubDir%"=="" set DstDllDir=%DstDllDir%\%InstallLibSubDir%
if not exist %DstDllDir% mkdir %DstDllDir%

if exist %SrcLibDir%\*.dll copy /b %SrcLibDir%\*.dll %DstDllDir%\
if exist %SrcLibDir%\*.pdb copy /b %SrcLibDir%\*.pdb %DstDllDir%\
exit /b

rem
rem
:END
popd
endlocal
