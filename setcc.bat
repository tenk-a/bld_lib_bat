@echo off
rem This batch-file license: boost software license version 1.0
rem Please rewrite PATH according to your environment.

set INCLUDE=
set LIB=

if /i "%ProgramFiles(x86)%"=="" set "ProgramFiles(x86)=%ProgramFiles%"

if "%setcc_save_path%"=="" set "setcc_save_path=%path%"

set "setcc_base_path=%setcc_save_path%"
if not "%CcNasmDir%"==""  set "setcc_base_path=%CcNasmDir%;%setcc_base_path%"
if not "%CcCMakeDir%"=="" set "setcc_base_path=%CcCMakeDir%;%setcc_base_path%"
if not "%CcPerlDir%"==""  set "setcc_base_path=%CcPerlDir%;%setcc_base_path%"

set CcName=%1
set CcArch=%2

if "%CcArch%"==""    set CcArch=Win32
if "%CcArch%"=="x86" set CcArch=Win32

set CcNameArch=%CcName%
if /I not "%CcArch%"=="Win32" set "CcNameArch=%CcName%%CcArch%"

rem
if /i "%CcNameArch%"=="vc141"      goto L_VC141
if /i "%CcNameArch%"=="vc141x64"   goto L_VC141x64
if /i "%CcNameArch%"=="vc140"      goto L_VC14
if /i "%CcNameArch%"=="vc140x64"   goto L_VC14x64
if /i "%CcNameArch%"=="vc130"      goto L_VC13
if /i "%CcNameArch%"=="vc130x64"   goto L_VC13x64
if /i "%CcNameArch%"=="vc120"      goto L_VC12
if /i "%CcNameArch%"=="vc120x64"   goto L_VC12x64
if /i "%CcNameArch%"=="vc110"      goto L_VC11
if /i "%CcNameArch%"=="vc110x64"   goto L_VC11x64
if /i "%CcNameArch%"=="vc100"      goto L_VC10
if /i "%CcNameArch%"=="vc100x64"   goto L_VC10x64
if /i "%CcNameArch%"=="vc90"       goto L_VC9
if /i "%CcNameArch%"=="vc90x64"    goto L_VC9x64
if /i "%CcNameArch%"=="vc80"       goto L_VC8
if /i "%CcNameArch%"=="vc80x64"    goto L_VC8x64
if /i "%CcNameArch%"=="vc71"       goto L_VC71
if /i "%CcNameArch%"=="vc70"       goto L_VC70
if /i "%CcNameArch%"=="vc60"       goto L_VC6

if /i "%CcNameArch%"=="vc14.1"     goto L_VC141
if /i "%CcNameArch%"=="vc14.1x64"  goto L_VC141x64
if /i "%CcNameArch%"=="vc14"       goto L_VC14
if /i "%CcNameArch%"=="vc14x64"    goto L_VC14x64
if /i "%CcNameArch%"=="vc13"       goto L_VC13
if /i "%CcNameArch%"=="vc13x64"    goto L_VC13x64
if /i "%CcNameArch%"=="vc12"       goto L_VC12
if /i "%CcNameArch%"=="vc12x64"    goto L_VC12x64
if /i "%CcNameArch%"=="vc11"       goto L_VC11
if /i "%CcNameArch%"=="vc11x64"    goto L_VC11x64
if /i "%CcNameArch%"=="vc10"       goto L_VC10
if /i "%CcNameArch%"=="vc10x64"    goto L_VC10x64
if /i "%CcNameArch%"=="vc9"        goto L_VC9
if /i "%CcNameArch%"=="vc9x64"     goto L_VC9x64
if /i "%CcNameArch%"=="vc8"        goto L_VC8
if /i "%CcNameArch%"=="vc8x64"     goto L_VC8x64
if /i "%CcNameArch%"=="vc7.1"      goto L_VC71
if /i "%CcNameArch%"=="vc7"        goto L_VC70
if /i "%CcNameArch%"=="vc6"        goto L_VC6

rem
if /i "%CcNameArch%"=="cygwin32"   goto L_CYGWIN32
if /i "%CcNameArch%"=="cygwin64"   goto L_CYGWIN64
if /i "%CcNameArch%"=="msys2"      goto L_MSYS2_64
if /i "%CcNameArch%"=="msys2_32"   goto L_MSYS2_32
if /i "%CcNameArch%"=="msys2_64"   goto L_MSYS2_64
if /i "%CcNameArch%"=="msys32"     goto L_MSYS2_32
if /i "%CcNameArch%"=="msys64"     goto L_MSYS2_64
if /i "%CcNameArch%"=="clang64"    goto L_MSYS2_64
if /i "%CcNameArch%"=="msys2clang32" goto L_MSYS2_32
if /i "%CcNameArch%"=="msys2clang64" goto L_MSYS2_64
if /i "%CcNameArch%"=="msys2mingw32" goto L_MSYS2_32
if /i "%CcNameArch%"=="msys2mingw64" goto L_MSYS2_64
if /i "%CcNameArch%"=="mingw32"    goto L_MINGW32
if /i "%CcNameArch%"=="mingw64"    goto L_MINGW64
if /i "%CcNameArch%"=="tdm32"      goto L_TDM32
if /i "%CcNameArch%"=="tdm64"      goto L_TDM64
if /i "%CcNameArch%"=="orangec"    goto L_ORANGEC
if /i "%CcNameArch%"=="occ"        goto L_ORANGEC
if /i "%CcNameArch%"=="dmc"        goto L_DMC
if /i "%CcNameArch%"=="bcc32c"     goto L_BCC101
if /i "%CcNameArch%"=="bcc101"     goto L_BCC101
if /i "%CcNameArch%"=="bcc32"      goto L_BCC55
if /i "%CcNameArch%"=="bc55"       goto L_BCC55
if /i "%CcNameArch%"=="ow"         goto L_OW19
if /i "%CcNameArch%"=="ow19"       goto L_OW19
if /i "%CcNameArch%"=="ow20"       goto L_OW20

rem
if /i "%CcNameArch%"=="tinyc"       goto L_TINYC32
if /i "%CcNameArch%"=="tcc"         goto L_TINYC32
if /i "%CcNameArch%"=="tinyc64"     goto L_TINYC64
if /i "%CcNameArch%"=="tcc64"       goto L_TINYC64
if /i "%CcNameArch%"=="pcc"         goto L_PCC
if /i "%CcNameArch%"=="pocc"        goto L_PELLESC32
if /i "%CcNameArch%"=="pellesc"     goto L_PELLESC32
if /i "%CcNameArch%"=="pocc64"      goto L_PELLESC64
if /i "%CcNameArch%"=="pellesc64"   goto L_PELLESC64
if /i "%CcNameArch%"=="lcc"         goto L_LCC
if /i "%CcNameArch%"=="lccwin"      goto L_LCCWIN
if /i "%CcNameArch%"=="lccwin64"    goto L_LCCWIN64
if /i "%CcNameArch%"=="coins"       goto L_COINS
if /i "%CcNameArch%"=="lsic86"      goto L_LSIC86

rem
if /i "%CcNameArch%"=="rust"        goto L_RUST
if /i "%CcNameArch%"=="dmd1"        goto L_DMD1
if /i "%CcNameArch%"=="dmd2"        goto L_DMD2
if /i "%CcNameArch%"=="ldc2"        goto L_LDC2
if /i "%CcNameArch%"=="go"          goto L_GO
if /i "%CcNameArch%"=="java"        goto L_JAVA


@echo setcc [COMPILER] [x86/x64]
@echo   COMPILER:
@echo       vc141,vc140,vc120,vc110,vc100,vc90,vc80
@echo       vc141x64,vc140x64,vc120x64,vc110x64,vc100x64,vc90x64,vc80x64
@echo       tdm32,mingw32,cygwin32,oragnec,dmc,bcc32c,bc55,ow19,ow20
@echo       tdm64,mingw64,cygwin64
@echo       tinyc,pcc,pellesc,lccwin
@echo       tinyc64,pcc64,pellesc64,lccwin64
@goto L_END


rem ## vc ######################################

:L_VC141
    set COMPILER=vc141
    set "PATH=%setcc_base_path%"
    if /i "%VC141_DIR%"=="" set "VC141_DIR=%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Community"
    pushd .
    call "%VC141_DIR%\Common7\Tools\VsMSBuildCmd.bat"
    call "%VC141_DIR%\VC\Auxiliary\Build\vcvars32.bat"
    popd
    goto L_END

:L_VC141x64
    set COMPILER=vc141x64
    call :C_VC141x64
    goto L_END

:C_VC141x64
    set "PATH=%setcc_base_path%"
    if /i "%VC141_DIR%"=="" set "VC141_DIR=%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Community"
    pushd .
    call "%VC141_DIR%\Common7\Tools\VsMSBuildCmd.bat"
    call "%VC141_DIR%\VC\Auxiliary\Build\vcvars64.bat"
    popd
    exit /b

:L_VC14
    set COMPILER=vc140
    set "PATH=%setcc_base_path%"
    call "%VS140COMNTOOLS%vsvars32.bat"
    goto L_END

:L_VC14x64
    set COMPILER=vc140x64
    set "PATH=%setcc_base_path%"
    call "%VS140COMNTOOLS%..\..\vc\bin\amd64\vcvars64.bat"
    goto L_END

:L_VC12
    set COMPILER=vc120
    set "PATH=%setcc_base_path%"
    call "%VS120COMNTOOLS%vsvars32.bat"
    goto L_END

:L_VC12x64
    set COMPILER=vc120x64
    set "PATH=%setcc_base_path%"
    call "%VS120COMNTOOLS%..\..\vc\bin\amd64\vcvars64.bat"
    goto L_END

:L_VC11
    set COMPILER=vc110
    set "PATH=%setcc_base_path%"
    call "%VS110COMNTOOLS%vsvars32.bat"
    goto L_END

:L_VC11x64
    set COMPILER=vc110x64
    set "PATH=%setcc_base_path%"
    call "%VS110COMNTOOLS%..\..\vc\bin\amd64\vcvars64.bat"
    goto L_END

:L_VC10
    set COMPILER=vc100
    set "PATH=%setcc_base_path%"
    call "%VS100COMNTOOLS%vsvars32.bat"
    goto L_END

:L_VC10x64
    set COMPILER=vc100x64
    set "PATH=%setcc_base_path%"
    call "%VS100COMNTOOLS%..\..\vc\bin\amd64\vcvarsamd64.bat"
    goto L_END

:L_VC9
    set COMPILER=vc90
    set "PATH=%setcc_base_path%"
    call "%VS90COMNTOOLS%vsvars32.bat"
    goto L_END

:L_VC9x64
    set COMPILER=vc90x64
    set "PATH=%setcc_base_path%"
    call "%VS90COMNTOOLS%..\..\vc\bin\amd64\vcvarsamd64.bat"
    goto L_END

:L_VC8
    set COMPILER=vc80
    set "PATH=%setcc_base_path%"
    call "%VS80COMNTOOLS%vsvars32.bat"
    goto L_END

:L_VC8x64
    set COMPILER=vc80x64
    set "PATH=%setcc_base_path%"
    call "%VS80COMNTOOLS%..\..\vc\bin\amd64\vcvarsamd64.bat"
    goto L_END

:L_VC71
    set COMPILER=vc71
    set "PATH=%setcc_base_path%"
    if /i "%VS71_DIR%"=="" set "VS71_DIR=%ProgramFiles(x86)%\Microsoft Visual Studio .NET 2003"
    if /i "%VS71COMNTOOLS%"=="" set "VS71COMNTOOLS=%VS71_DIR%\Common7\Tools\"
    set "INCLUDE=%VS71_DIR%\SDK\v1.1\include\"
    set "LIB=%VS71_DIR%\SDK\v1.1\Lib\"
    call "%VS71COMNTOOLS%vsvars32.bat"
    goto L_END

:L_VC70
    set COMPILER=vc70
    set "PATH=%setcc_base_path%"
    if /i "%VS70_DIR%"=="" set "VS70_DIR=%ProgramFiles(x86)%\Microsoft Visual Studio .NET"
    if /i "%VS70COMNTOOLS%"=="" set "VS70COMNTOOLS=%VS70_DIR%\Common7\Tools\"
    call "%VS70COMNTOOLS%vsvars32.bat"
    goto L_END

:L_VC6
    set COMPILER=vc60
    set "PATH=%setcc_base_path%"
    if /i "%VS6_DIR%"=="" set "VS6_DIR=%ProgramFiles(x86)%\Microsoft Visual Studio"
    if /i "%VS60COMNTOOLS%"=="" set "VS60COMNTOOLS=%VS6_DIR%\Common\Tools\"
    call "%VS6_DIR%\vc6\bin\vcvars32.bat"
    goto L_END


rem ## c++ ######################################

:L_CYGWIN32
    set COMPILER=cygwin32
    if /i "%CYGWIN32_DIR%"=="" set "CYGWIN_DIR32=c:\cygwin"
    set "PATH=%CYGWIN_DIR32%\bin;%setcc_base_path%"
    goto :L_END

:L_CYGWIN64
    set COMPILER=cygwin64
    if /i "%CYGWIN64_DIR%"=="" set "CYGWIN64_DIR=c:\cygwin64"
    set "PATH=%CYGWIN64_DIR%\bin;%setcc_base_path%"
    goto :L_END

:L_MSYS2_32
    set COMPILER=msys2mingw32
    if /i "%MSYS2_DIR%"=="" set "MSYS2_DIR=c:\msys64"
    set "PATH=%MSYS2_DIR%\mingw32\bin;%MSYS2_DIR%\usr\bin;%setcc_base_path%"
    goto :L_END

:L_MSYS2_64
    set COMPILER=msys2mingw64
    if /i "%MSYS2_DIR%"=="" set "MSYS2_DIR=c:\msys64"
    set "PATH=%MSYS2_DIR%\mingw64\bin;%MSYS2_DIR%\usr\bin;%setcc_base_path%"
    goto :L_END

:L_MINGW32
    set COMPILER=mingw32
    if /i "%MINGW32_DIR%"=="" set "MINGW32_DIR=c:\Mingw"
    set "PATH=%MINGW32_DIR%\bin;%setcc_base_path%"
    goto :L_END

:L_MINGW64
    set COMPILER=mingw64
    if /i "%MINGW64_DIR%"=="" set "MINGW64_DIR=%ProgramFiles%\mingw-w64\x86_64-7.2.0-posix-seh-rt_v5-rev0\mingw64"
    set "PATH=%MINGW64_DIR%\bin;%setcc_base_path%"
    goto :L_END

:L_TDM32
    set COMPILER=tdm32
    if /i "%TDM32_DIR%"=="" set "TDM32_DIR=c:\TDM-GCC-32"
    set "PATH=%TDM32_DIR%\bin;%setcc_base_path%"
    goto :L_END

:L_TDM64
    set COMPILER=tdm64
    if /i "%TDM64_DIR%"=="" set "TDM64_DIR=c:\TDM-GCC-64"
    set "PATH=%TDM64_DIR%\bin;%setcc_base_path%"
    goto :L_END

:L_ORANGEC
    set COMPILER=orangec
    if /i "%ORANGEC_DIR%"=="" set "ORANGEC_DIR=C:\Program Files (x86)\Orange C 386"
    set "PATH=%ORANGEC_DIR%\bin;%setcc_base_path%"
    goto :L_END

:L_DMC
    set COMPILER=dmc
    if /i "%DMC_DIR%"=="" set "DMC_DIR=c:\dm"
    set "PATH=%DMC_DIR%\bin;%setcc_base_path%"
    goto :L_END

:L_BCC101
    set COMPILER=bcc32c
    if /i "%BCC32C_DIR%"=="" set "BCC32C_DIR=c:\bcc101"
    set "PATH=%BCC32C_DIR%\bin;%setcc_base_path%"
    goto :L_END

:L_BCC55
    set COMPILER=bc55
    if /i "%BC55_DIR%"=="" set "c:\borland\bcc55"
    set "PATH=%BC55_DIR%\bin;%setcc_base_path%"
    set "INCLUDE=%BC55_DIR%\include;%BC55_DIR%\include\Rw;%BC55_DIR%\include\psdk"
    goto :L_END

:L_OW19
    set COMPILER=ow19
    if /i "%OW19_DIR%"=="" set "c:\watcom1.9"
    set "WATCOM=%OW19_DIR%"
    set "PATH=%WATCOM%\BINNT;%WATCOM%\BINW;%setcc_base_path%"
    set "EDPATH=%WATCOM%\EDDAT"
    set "INCLUDE=%WATCOM%\H;%WATCOM%\H\NT;%INCLUDE%"
    set "FINCLUDE=%WATCOM%\SRC\FORTRAN"
    goto :L_END

:L_OW20
    set COMPILER=ow20
    if /i "%OW20_DIR%"=="" set "c:\watcom2.0"
    set "WATCOM=%OW20_DIR%"
    set "PATH=%WATCOM%\BINNT;%WATCOM%\BINW;%setcc_base_path%"
    set "EDPATH=%WATCOM%\EDDAT"
    set "INCLUDE=%WATCOM%\H;%WATCOM%\H\NT;%INCLUDE%"
    set "FINCLUDE=%WATCOM%\SRC\FORTRAN"
    goto :L_END



rem ## c ######################################

:L_PELLESC32
    set "COMPILER=pellesc"
    set "PellesC_Dir=%ProgramFiles(x86)%\PellesC"
    set "PATH=%PellesC_Dir%\bin;%setcc_base_path%"
    set "INCLUDE=%PellesC_Dir%\include;%PellesC_Dir%\include\win;%INCLUDE%"
    set "LIB=%PellesC_Dir%\lib;%PellesC_Dir%\lib\win;%LIB%"
    goto :L_END

:L_PELLESC64
    set "COMPILER=pellesc64"
    set "PellesC64_Dir=%ProgramFiles%\PellesC"
    set "PATH=%PellesC64_Dir%\bin;%setcc_base_path%"
    set "INCLUDE=%PellesC64_Dir%\include;%PellesC64_Dir%\include\win;%INCLUDE%"
    set "LIB=%PellesC64_Dir%\lib;%PellesC64_Dir%\lib\win64;%LIB%"
    goto :L_END

:L_LCCWIN32
    set "COMPILER=lccwin32"
    if /i "%LCCWIN32_DIR%"=="" set "LCCWIN32_DIR=c:\lccwin32"
    set "PATH=%LCCWIN32_DIR%\bin;%setcc_base_path%"
    set "INCLUDE=%LCCWIN32_DIR%\include;%INCLUDE%"
    goto :L_END

:L_LCCWIN64
    set "COMPILER=lccwin64"
    if /i "%LCCWIN64_DIR%"=="" set "LCCWIN64_DIR=c:\lccwin64"
    set "PATH=%LCCWIN64_DIR%\bin;%setcc_base_path%"
    set "INCLUDE=%LCCWIN64_DIR%\include;%INCLUDE%"
    goto :L_END

:L_LCC
    set "COMPILER=lcc"
    if /i "%LCC_DIR%"=="" set "LCC_DIR=c:\tools\lcc"
    set "PATH=%LCC_DIR%\bin;%setcc_base_path%"
    goto :L_END


:L_TINYC32
    set "COMPILER=tinyc"
    if /i "%TINYC_DIR%"=="" set "TINYC_DIR=c:\tools\tcc-0.9.26win32"
    set "PATH=%TINYC_DIR%;%setcc_base_path%"
    goto :L_END

:L_TINYC64
    set "COMPILER=tinyc64"
    if /i "%TINYC64_DIR%"=="" set "TINYC64_DIR=c:\tools\tcc-0.9.26win64"
    set "PATH=%TINYC64_DIR%;%setcc_base_path%"
    goto :L_END

:L_PCC
    set "COMPILER=pcc"
    if /i "%PCC_DIR%"=="" set "PCC_DIR=c:\tools\pcc"
    set "PATH=%PCC_DIR%\bin;%setcc_base_path%"
    goto :L_END

:L_COINS
    set "COMPILER=coins"
    if /i "%COINS_DIR%"=="" set "COINS_DIR=c:\tools\coins-1.5-en"
    if /i "%CYGWIN32_DIR%"=="" set "CYGWIN_DIR32=c:\cygwin"
    set "PATH=%COINS_DIR%\bin;%CYGWIN_DIR32%\bin;%JAVA_HOME%\bin;%setcc_base_path%"
    goto :L_END


:L_LSIC86
    set "COMPILER=lsic86"
    set "PATH=c:\tools\lsic330c\bin;c:\bin;%windir%\system32;%windir%;"
    goto :L_END




rem ## other ######################################

:L_RUST
    set "COMPILER=rust"
    rem if /i "%RUST_DIR%"=="" set "RUST_DIR=%ProgramFiles%\Rust stable MSVC 1.13"
    rem set "PATH=%RUST_DIR%\bin;%setcc_base_path%"
    set "PATH=%USERPATH%\.cargo\bin;%setcc_base_path%"
    goto :L_END

:L_DMD2
    set "COMPILER=dmd2"
    if /i "%DMD2_DIR%"=="" set "DMD2_DIR=c:\D\dmd2"
    if /i "%DMC_DIR%"=="" set "DMC_DIR=c:\dm"
    set "PATH=%DMD2_DIR%\windows\bin;%DMC_DIR%\bin;%setcc_base_path%"
    goto :L_END

:L_DMD1
    set "COMPILER=dmd1"
    if /i "%DMD1_DIR%"=="" set "DMD1_DIR=c:\D\dmd1"
    if /i "%DMC_DIR%"=="" set "DMC_DIR=c:\dm"
    set "PATH=%DMD1_DIR%\windows\bin;%DMC_DIR%\bin;%setcc_base_path%"
    goto :L_END

:L_LDC2
    set "COMPILER=ldc2"
    rem call :C_VC141x64
    if /i "%LDC2_DIR%"=="" set "LDC2_DIR=c:\tools\ldc2-1.6.0-beta1-win64-msvc"
    set "PATH=%LDC2_DIR%\bin;%setcc_base_path%"
    goto :L_END

:L_GO
    set "COMPILER=go"
    if /i "%GO_DIR%"=="" set "GO_DIR=c:\go"
    set "PATH=%GO_DIR%\bin;%setcc_base_path%"
    goto :L_END


:L_JAVA
    set "COMPILER=java"
    if /i "JAVA_HOME"=="" set "JAVA_HOME=%ProgramFiles%\Java\jdk1.8.0_152"
    if /i "JRE_DIR"==""   set "JRE_DIR=%ProgramFiles%\Java\jre1.8.0_152"
    set "PATH=%JAVA_HOME%\bin;%JRE_DIR%\bin;%setcc_base_path%"
    if /i not "ANT_HOME"=="" set "PATH=%ANT_HOME%\bin;%PATH%"
    goto :L_END


:L_END
set setcc_base_path=
set CcNameArch=
