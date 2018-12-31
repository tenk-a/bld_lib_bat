@echo off
rem Compile libjpeg-turbo for vc
rem usage: bld1_libjpeg-turbo [win32/x64] [debug/release] [clean]
rem ex)
rem cd libjpeg-turbo-???
rem ..\bld_lib_bat\bld1_libjpeg-turbo.bat x64
rem
rem This batch-file license: boost software license version 1.0
setlocal

set Arch=
set LibDir=
set StrPrefix=
set StrRel=_release
set StrDbg=_debug
set StrRtSta=_static
set StrRtDll=
set StrDll=_dll

set HasRel=
set HasDbg=
set HasRtSta=
set HasRtDll=
rem set HasTest=
set CleanMode=
set VcVer=

:ARG_LOOP
  if "%1"=="" goto ARG_LOOP_EXIT

  if /I "%1"=="x86"      set Arch=Win32
  if /I "%1"=="Win32"    set Arch=Win32
  if /I "%1"=="x64"      set Arch=x64

  if /I "%1"=="static"   set HasRtSta=S
  if /I "%1"=="rtsta"    set HasRtSta=S
  if /I "%1"=="rtdll"    set HasRtDll=L

  if /I "%1"=="release"  set HasRel=r
  if /I "%1"=="debug"    set HasDbg=d

  if /I "%1"=="clean"    set CleanMode=1

  rem if /I "%1"=="test"     set HasTest=1

  if /I "%1"=="vc71"     set VcVer=vc71
  if /I "%1"=="vc80"     set VcVer=vc80
  if /I "%1"=="vc90"     set VcVer=vc90
  if /I "%1"=="vc100"    set VcVer=vc100
  if /I "%1"=="vc110"    set VcVer=vc110
  if /I "%1"=="vc120"    set VcVer=vc120
  if /I "%1"=="vc130"    set VcVer=vc130
  if /I "%1"=="vc140"    set VcVer=vc140
  if /I "%1"=="vc141"    set VcVer=vc141

  set ARG=%1
  if /I "%ARG:~0,7%"=="LibDir:"     set LibDir=%ARG:~7%
  if /I "%ARG:~0,10%"=="LibPrefix:" set StrPrefix=%ARG:~10%
  if /I "%ARG:~0,9%"=="LibRtSta:"   set StrRtSta=%ARG:~9%
  if /I "%ARG:~0,9%"=="LibRtDll:"   set StrRtDll=%ARG:~9%
  if /I "%ARG:~0,7%"=="LibRel:"     set StrRel=%ARG:~7%
  if /I "%ARG:~0,7%"=="LibDbg:"     set StrDbg=%ARG:~7%

  shift
goto ARG_LOOP
:ARG_LOOP_EXIT

if "%VcVer%"=="" (
  if /I not "%PATH:Microsoft Visual Studio .NET 2003=%"=="%PATH%" set VcVer=vc71
  if /I not "%PATH:Microsoft Visual Studio 8=%"=="%PATH%"    set VcVer=vc80
  if /I not "%PATH:Microsoft Visual Studio 9.0=%"=="%PATH%"  set VcVer=vc90
  if /I not "%PATH:Microsoft Visual Studio 10.0=%"=="%PATH%" set VcVer=vc100
  if /I not "%PATH:Microsoft Visual Studio 11.0=%"=="%PATH%" set VcVer=vc110
  if /I not "%PATH:Microsoft Visual Studio 12.0=%"=="%PATH%" set VcVer=vc120
  if /I not "%PATH:Microsoft Visual Studio 13.0=%"=="%PATH%" set VcVer=vc130
  if /I not "%PATH:Microsoft Visual Studio 14.0=%"=="%PATH%" set VcVer=vc140
  if /I not "%PATH:Microsoft Visual Studio\2017=%"=="%PATH%" set VcVer=vc141
)

if "%StrPrefix%"=="" (
  if not "%VcVer%"=="" (
    if "%StrPrefix%"=="" set StrPrefix=%VcVer%_
  )
)

if "%Arch%"=="" (
  if "%VcVer%"=="vc141"    if /I not "%PATH:\bin\HostX64\x64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 14.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 13.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 12.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 11.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 10.0\VC\BIN\amd64=%"=="%PATH%" set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 9.0\VC\BIN\amd64=%"=="%PATH%"  set Arch=x64
  if /I not "%PATH:Microsoft Visual Studio 8\VC\BIN\amd64=%"=="%PATH%"    set Arch=x64
)
if "%Arch%"=="" set Arch=Win32

call :Clean
if "%CleanMode%"=="1" goto :EOF

if "%HasRtSta%%HasRtDll%"=="" (
  set HasRtSta=S
  set HasRtDll=L
)
if "%HasRel%%HasDbg%"=="" (
  set HasRel=r
  set HasDbg=d
)

if "%LibDir%"=="" set LibDir=lib
if not exist %LibDir% mkdir %LibDir%

if not exist jconfig.h copy jconfig.vc jconfig.h

if "%HasRtSta%%HasRel%"=="Sr" call :Bld1 rtsta release %StrPrefix%%Arch%%StrRtSta%%StrRel%
if "%HasRtSta%%HasDbg%"=="Sd" call :Bld1 rtsta debug   %StrPrefix%%Arch%%StrRtSta%%StrDbg%
if "%HasRtDll%%HasRel%"=="Lr" call :Bld1 rtdll release %StrPrefix%%Arch%%StrRtDll%%StrRel%
if "%HasRtDll%%HasDbg%"=="Ld" call :Bld1 rtdll debug   %StrPrefix%%Arch%%StrRtDll%%StrDbg%

endlocal
goto :EOF


:Bld1
set RtType=%1
set BldType=%2
set Target=%3

call :Clean

set ADD_CMAKE_OPTS=
if %RtType%==rtdll (
    set ADD_CMAKE_OPTS=-DWITH_CRT_DLL=true
) else (
    set ADD_CMAKE_OPTS=-DWITH_CRT_DLL=false
)
CMake -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=%BldType% %ADD_CMAKE_OPTS%
if errorlevel 1 goto :EOF

rem if %RtType%==rtdll (
rem   call :ReplaceMTtoMD
rem )
if %RtType%==rtsta (
    call :ReplaceMDtoMT
)

nmake
if errorlevel 1 goto :EOF

set DstDir=%LibDir%\%Target%
if not exist %DstDir% mkdir %DstDir%
if not exist %DstDir%\exe mkdir %DstDir%\exe

del *.obj *.res *.resource.txt *.manifest *.exp *.ilk

if exist *.lib move *.lib %DstDir%\
if exist *.dll move *.dll %DstDir%\
if exist turbojpeg.pdb move turbojpeg.pdb %DstDir%\
if exist sharedlib\*.lib move sharedlib\*.lib %DstDir%\
if exist sharedlib\*.dll move sharedlib\*.dll %DstDir%\
if exist sharedlib\jpeg.pdb move sharedlib\jpeg.pdb %DstDir%\

if exist *.exe move *.exe %DstDir%\exe\
if exist *.pdb move *.pdb %DstDir%\exe\
if exist sharedlib\*.exe move sharedlib\*.exe %DstDir%\exe\
if exist sharedlib\*.pdb move sharedlib\*.pdb %DstDir%\exe\

exit /b


:Clean
if exist Makefile (
  nmake clean
  del Makefile
)
if exist CMakeFiles (
  del /S /F /Q CMakeFiles\*.*
  rmdir /S /Q CMakeFiles
)
if exist jconfig.h           del jconfig.h
if exist jconfigint.h        del jconfigint.h
if exist CMakeCache.txt      del CMakeCache.txt
if exist cmake_install.cmake del cmake_install.cmake
if exist CTestTestfile.cmake del CTestTestfile.cmake
if exist libjpeg-turbo.nsi   del libjpeg-turbo.nsi
if exist turbojpeg.exp	     del turbojpeg.exp
if exist install_manifest.txt del install_manifest.txt

cd simd
if exist Makefile (
  nmake clean
  del Makefile
)
if exist CMakeFiles (
  del /S /F /Q CMakeFiles\*.*
  rmdir /S /Q CMakeFiles
)
if exist cmake_install.cmake del cmake_install.cmake
cd ..
cd sharedlib
if exist Makefile (
  nmake clean
  del Makefile
)
del *.manifest *.manifest.res *.resource.txt *.ilk
if exist CMakeFiles (
  del /S /F /Q CMakeFiles\*.*
  rmdir /S /Q CMakeFiles
)
if exist cmake_install.cmake del cmake_install.cmake
if exist jpeg.exp	     del jpeg.exp
cd ..

exit /b


:ReplaceMTtoMD
for /R %%i in (CMakeCache.txt) do (
  if exist %%i call :Rep1MTtoMD %%i
)
exit /b
:Rep1MTtoMD
set TgtReplFile=%1
set BakReplFile=%1.bak
if exist %BakReplFile% del %BakReplFile%
move %TgtReplFile% %BakReplFile%
type nul >%TgtReplFile%
for /f "delims=" %%A in (%BakReplFile%) do (
    set line=%%A
    call :Rep1SubMTtoMD
)
exit /b
:Rep1SubMTtoMD
echo %line:/MT=/MD%>>%TgtReplFile%
exit /b


:ReplaceMDtoMT
for /R %%i in (CMakeCache.txt) do (
  if exist %%i call :Rep1MDtoMT %%i
)
exit /b
:Rep1MDtoMT
set TgtReplFile=%1
set BakReplFile=%1.bak
if exist %BakReplFile% del %BakReplFile%
move %TgtReplFile% %BakReplFile%
type nul >%TgtReplFile%
for /f "delims=" %%A in (%BakReplFile%) do (
    set line=%%A
    call :Rep1SubMDtoMT
)
exit /b
:Rep1SubMDtoMT
echo %line:/MD=/MT%>>%TgtReplFile%
exit /b
