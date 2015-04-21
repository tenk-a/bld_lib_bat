rem @echo off
rem This batch-file license: boost software license version 1.0
rem ==========================================================================
rem user setting

rem vc8,vc9,vc10,vc11,vc12,vc13
set CcName=vc12

rem (VC++ Express Edition: CcHasX64=0 CcNoRtStatic=1)
set CcHasX64=1
set CcNoRtStatic=

rem for glfw, libjpeg-turbo
set CcCMakeDir=%ProgramFiles(x86)%\CMake\bin

rem for libjpeg-turbo
set CcNasmDir=c:\tools\nasm


rem ==========================================================================
rem

set CcLibDir=.\lib
rem set CcLibPrefix=vc_
set CcLibPrefix=%CcName%_
set CcLibStrDebug=_debug
set CcLibStrRelease=
set CcLibStrDll=_dll
set CcLibStrStatic=_static
set CcLibStrRtDll=

set CcMiscIncDir=misc_inc
set CcMiscLibDir=misc_lib


rem set CcZlibDir=zlib-1.2.8
rem set CcBzip2Dir=bzip2-1.0.6
rem set CcBoostDir=boost_1_57_0
rem set CcWxWidgets=wxWidgets-3.0.2
rem set CcBoostDir=boost_1_57_0
rem set CcLibJpegDir=jpeg-9a
rem set CcLibJpegTurboDir=libjpeg-turbo-code-1537-trunk
