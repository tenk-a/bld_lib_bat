rem @echo off
rem This batch-file license: boost software license version 1.0
rem ==========================================================================
rem user setting


rem ==========================================================================
if not "%CcLibsRoot%"=="" goto :EOF

rem Directory for installing libraries.
set CcLibsRoot=..

rem Include directory containing build results.
set CcInstallIncDir=..\..\include

rem Lib directory containing build results.
set CcInstallLibDir=..\..\lib

rem dll directory containing build results.
set CcInstallDllDir=..\..\dll

rem Lib directory path type.
rem D_=Directory J_=Join   V=VC-Name A=Arch R=Runtime
rem D_VAR D_VRA D_AVR D_ARV D_RVA D_RAV D_VA D_AV
rem S_VAR S_VRA S_AVR S_ARV S_RVA S_RAV J_VA J_AV
rem ex) D_VAR -> vc142\x64\static\release
rem ex) S_ARV -> Win32_rtdll_vc120\debug
rem ex) D_VA  -> vc140\x64\release_static
set CcInstallPathType=D_VA

rem ?_VA|?_AV: add runtime's string.
set CcStrRtDll=
set CcStrStatic=_static
set CcStrDll=_dll

rem Target Library setting.
set CcTgtLibDir=lib
set CcTgtLibPathType=J_VA


rem ==========================================================================
rem TOOL's setting

rem for glfw, libjpeg-turbo, openssl etc
set CcCMakeDir=%ProgramFiles%\CMake\bin

rem for libjpeg-turbo, OpenSSL
set CcNasmDir=%USERPROFILE%\AppData\Local\bin\nasm

rem for openssl
set CcPerlDir=c:\Perl64\site\bin;c:\Perl64\bin

rem Python3 for OpenCV
set CcPythonDir=%USERPROFILE%\AppData\Local\Programs\Python
set CcPython3Path=%CcPythonDir%\Python37\Scripts\;%CcPythonDir%\Python37\;%CcPythonDir%\Launcher\;
rem python is installed on Win32 or x64. Do not use undefined. *OpenCV: Now defining debug build fails with python??_d.lib error not found.
set CcPythonPlatform=

rem for pixman
rem set CcWinGnuMake=C:\tools\MinGW_Msys1\bin\mingw32-make.exe
set CcWinGnuMake=C:\mozilla-build\bin\mozmake.exe

rem for cairo
rem set CcMsys1Paths=C:\tools\MinGW_Msys1\1.0\msys\local\bin;C:\tools\MinGW_Msys1\msys\1.0\bin
set CcMsys1Paths=C:\mozilla-build\msys\local\bin;C:\mozilla-build\msys\bin


rem ==========================================================================
rem

rem set CcLibPrefix=%CcName%_
set CcStrDebug=_debug
set CcStrRelease=_release
set CcStrRtDll=
set CcStrDll=_dll
set CcStrStatic=_static
set CcBld1Arg=
