@echo off
rem This batch-file license: boost software license version 1.0

set INCLUDE=
set LIB=

if "%setcc_save_path%"=="" set "setcc_save_path=%path%"

set "setcc_base_path=%setcc_save_path%"
if not "%CcNasmDir%"==""  set "setcc_base_path=%CcNasmDir%;%setcc_base_path%"
if not "%CcCMakeDir%"=="" set "setcc_base_path=%CcCMakeDir%;%setcc_base_path%"

set CcName=%1
set CcArch=%2

if "%CcArch%"=="" set CcArch=x86

set CcNameArch=%CcName%
if not "%CcArch%"=="x86" set CcNameArch=%CcName%%CcArch%

if "%CcNameArch%"=="vc130"    goto L_VC13
if "%CcNameArch%"=="vc130x64" goto L_VC13x64
if "%CcNameArch%"=="vc120"    goto L_VC12
if "%CcNameArch%"=="vc120x64" goto L_VC12x64
if "%CcNameArch%"=="vc110"    goto L_VC11
if "%CcNameArch%"=="vc110x64" goto L_VC11x64
if "%CcNameArch%"=="vc100"    goto L_VC10
if "%CcNameArch%"=="vc100x64" goto L_VC10x64
if "%CcNameArch%"=="vc90"     goto L_VC9
if "%CcNameArch%"=="vc90x64"  goto L_VC9x64
if "%CcNameArch%"=="vc80"     goto L_VC8
if "%CcNameArch%"=="vc80x64"  goto L_VC8x64
if "%CcNameArch%"=="vc71"    goto L_VC71
if "%CcNameArch%"=="vc13"    goto L_VC13
if "%CcNameArch%"=="vc13x64" goto L_VC13x64
if "%CcNameArch%"=="vc12"    goto L_VC12
if "%CcNameArch%"=="vc12x64" goto L_VC12x64
if "%CcNameArch%"=="vc11"    goto L_VC11
if "%CcNameArch%"=="vc11x64" goto L_VC11x64
if "%CcNameArch%"=="vc10"    goto L_VC10
if "%CcNameArch%"=="vc10x64" goto L_VC10x64
if "%CcNameArch%"=="vc9"     goto L_VC9
if "%CcNameArch%"=="vc9x64"  goto L_VC9x64
if "%CcNameArch%"=="vc8"     goto L_VC8
if "%CcNameArch%"=="vc8x64"  goto L_VC8x64

echo setcc [COMPILER] [x86/x64]
echo   COMPILER:
echo       vc120,vc110,vc100,vc90,vc80,vc71
goto L_END

:L_VC13
    set "PATH=%setcc_base_path%"
    call "%VS130COMNTOOLS%vsvars32.bat"
    goto L_END

:L_VC13x64
    set "PATH=%setcc_base_path%"
    call "%VS130COMNTOOLS%..\..\vc\bin\amd64\vcvars64.bat"
    goto L_VC_COMMON_X64

:L_VC12
    set "PATH=%setcc_base_path%"
    call "%VS120COMNTOOLS%vsvars32.bat"
    goto L_END

:L_VC12x64
    set "PATH=%setcc_base_path%"
    call "%VS120COMNTOOLS%..\..\vc\bin\amd64\vcvars64.bat"
    goto L_VC_COMMON_X64

:L_VC11
    set "PATH=%setcc_base_path%"
    call "%VS110COMNTOOLS%vsvars32.bat"
    goto L_VC_CMN

:L_VC11x64
    set "PATH=%setcc_base_path%"
    call "%VS110COMNTOOLS%..\..\vc\bin\amd64\vcvars64.bat"
    goto L_VC_CMN64

:L_VC10
    set "PATH=%setcc_base_path%"
    call "%VS100COMNTOOLS%vsvars32.bat"
    goto L_VC_CMN

:L_VC10x64
    set "PATH=%setcc_base_path%"
    call "%VS100COMNTOOLS%..\..\vc\bin\amd64\vcvarsamd64.bat"
    goto L_VC_CMN64

:L_VC9
    set "PATH=%setcc_base_path%"
    call "%VS90COMNTOOLS%vsvars32.bat"
    goto L_VC_CMN

:L_VC9x64
    set "PATH=%setcc_base_path%"
    call "%VS90COMNTOOLS%..\..\vc\bin\amd64\vcvarsamd64.bat"
    goto L_VC_COMMON_X64

:L_VC8
    set "PATH=%setcc_base_path%"
    call "%VS80COMNTOOLS%vsvars32.bat"
    goto L_VC_CMN

:L_VC8x64
    set "PATH=%setcc_base_path%"
    call "%VS80COMNTOOLS%..\..\vc\bin\amd64\vcvarsamd64.bat"
    goto L_VC_COMMON_X64

:L_VC_CMN
rem set "INCLUDE=%DXSDK_DIR%\include;%INCLUDE%"
rem set "LIB=%DXSDK_DIR%\lib\x86;%LIB%"
    goto L_END

:L_VC_COMMON_X64
rem set "INCLUDE=%DXSDK_DIR%\include;%INCLUDE%"
rem set "LIB=%DXSDK_DIR%\lib\x64;%LIB%"
    goto L_END

:L_END
set setcc_base_path=
set CcNameArch=
