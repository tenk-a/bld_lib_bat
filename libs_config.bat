rem @echo off
rem This batch-file license: boost software license version 1.0
rem ==========================================================================
rem user setting

rem vc8,vc9,vc10,vc11,vc12,vc13
set CcName=vc12

rem (VC++ Express Edition: CcHasX64=0 CcNoRtStatic=1)
set CcHasX64=1
set CcNoRtStatic=

rem for glfw, libjpeg-turbo etc
set CcCMakeDir=%ProgramFiles(x86)%\CMake\bin

rem for libjpeg-turbo
set CcNasmDir=%USERPROFILE%\AppData\Local\nasm
c:\tools\nasm


rem ==========================================================================
rem

if "%CcName%"=="" (
  echo Please set CcName in "libs_config.bat"
  pause
  exit
)

set CcLibDir=.\lib
set CcLibPrefix=
rem set CcLibPrefix=%CcName%_
set CcLibStrDebug=_debug
set CcLibStrRelease=
set CcLibStrDll=_dll
set CcLibStrStatic=_static
set CcLibStrRtDll=

set CcMiscIncDir=misc_inc
set CcMiscLibDir=misc_lib
