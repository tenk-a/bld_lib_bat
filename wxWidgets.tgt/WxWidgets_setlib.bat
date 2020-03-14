@rem @echo off
@rem WxWidgetsのsampleが元のフォルダ構成前提なので.
@rem ビルド済みのライブラリを もとのフォルダ構成にコピーする.
setlocal

set Arch=x64
set Rt=static
set Conf=release

:ARG_LOOP
  set A=%1

  if "%1"=="" goto ARG_LOOP_EXIT

  if /I "%1"=="x86"      set Arch=Win32
  if /I "%1"=="Win32"    set Arch=Win32
  if /I "%1"=="x64"      set Arch=x64
  if /I "%1"=="Win64"    set Arch=x64

  if /I "%1"=="static"   set Rt=static
  if /I "%1"=="rtdll"    set Rt=rtdll
  if /I "%1"=="dll"      set Rt=dll

  if /I "%1"=="release"  set Conf=release
  if /I "%1"=="debug"    set Conf=debug

  if /I "%1"=="vc80"     set VcVer=vc80
  if /I "%1"=="vc90"     set VcVer=vc90
  if /I "%1"=="vc100"    set VcVer=vc100
  if /I "%1"=="vc110"    set VcVer=vc110
  if /I "%1"=="vc120"    set VcVer=vc120
  if /I "%1"=="vc140"    set VcVer=vc140
  if /I "%1"=="vc141"    set VcVer=vc141
  if /I "%1"=="vc142"    set VcVer=vc142

  if /I "%1"=="vc2005"   set VcVer=vc80
  if /I "%1"=="vc2008"   set VcVer=vc90
  if /I "%1"=="vc2010"   set VcVer=vc100
  if /I "%1"=="vc2012"   set VcVer=vc110
  if /I "%1"=="vc2013"   set VcVer=vc120
  if /I "%1"=="vc2015"   set VcVer=vc140
  if /I "%1"=="vc2017"   set VcVer=vc141
  if /I "%1"=="vc2019"   set VcVer=vc142

  shift
goto ARG_LOOP
:ARG_LOOP_EXIT
set A=

if "%VcVer%"=="" goto ERR
if "%Arch%"=="" goto ERR
if "%Rt%"=="" goto ERR
if "%Conf%"=="" goto ERR

pushd %~dp0
pushd ..
call bld_config.bat
pushd %CcLibsRoot%
set CcLibsRoot=%CD%
popd
popd
call 01_init.bat

set StrLibPath=
call ..\sub\StrLibPath.bat %CcTgtLibPathType% %CcLibsRoot%\%TgtName%\%CcTgtLibDir% %VcVer% %Arch% %Rt% %Conf%
set SrcDir=%StrLibPath%

set DstDir=%CcLibsRoot%\%TgtName%\lib\vc
if "%Arch%"=="x64" set DstDir=%DstDir%_x64
if "%Rt%"=="dll" set DstDir=%DstDir%_dll
if not "%Rt%"=="dll" set DstDir=%DstDir%_lib

if exist %DstDir% rmdir /s /q %DstDir%
if not exist %DstDir% mkdir %DstDir%

xcopy %SrcDir% %DstDir% /R /Y /I /K /E

exit /b

:ERR
echo ERROR:
exit /b
