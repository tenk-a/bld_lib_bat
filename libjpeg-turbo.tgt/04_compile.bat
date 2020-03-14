@echo off
rem This batch-file license: boost software license version 1.0
setlocal

set VcVer=%1
shift
set Arch=%1
shift

set HasRel=
set HasDbg=
set HasRtSta=
set HasRtDll=
set HasTest=
set LibDir=
set StrPrefix=
set StrRel=_release
set StrDbg=_debug
set StrRtSta=_static
set StrRtDll=

set CleanMode=

:ARG_LOOP
  set ARG=%1

  if "%ARG%"=="" goto ARG_LOOP_EXIT
  if /I "%ARG%"=="static"   set HasRtSta=S
  if /I "%ARG%"=="rtdll"    set HasRtDll=L
  if /I "%ARG%"=="release"  set HasRel=r
  if /I "%ARG%"=="debug"    set HasDbg=d
  if /I "%ARG%"=="test"     set HasTest=1

  if /I "%1"=="clean"    set CleanMode=1

  if /I "%ARG:~0,7%"=="LibDir:"     set LibDir=%ARG:~7%
  if /I "%ARG:~0,10%"=="LibPrefix:" set StrPrefix=%ARG:~10%
  if /I "%ARG:~0,9%"=="LibRtSta:"   set StrRtSta=%ARG:~9%
  if /I "%ARG:~0,9%"=="LibRtDll:"   set StrRtDll=%ARG:~9%
  if /I "%ARG:~0,7%"=="LibRel:"     set StrRel=%ARG:~7%
  if /I "%ARG:~0,7%"=="LibDbg:"     set StrDbg=%ARG:~7%

  shift
goto ARG_LOOP
:ARG_LOOP_EXIT

if "%StrPrefix%"=="" (
  if not "%VcVer%"=="" (
    if "%StrPrefix%"=="" set StrPrefix=%VcVer%_
  )
)

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
if exist *.manifest     del *.manifest
if exist *.manifest.res del *.manifest.res
if exist *.resource.txt del *.resource.txt
if exist *.ilk          del *.ilk

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
..\bld_lib_bat\tiny_replstr.exe -x ++ "/MT" "/MD" -- %1
exit /b

rem	:Rep1MTtoMD
rem	set TgtReplFile=%1
rem	set BakReplFile=%1.bak
rem	if exist %BakReplFile% del %BakReplFile%
rem	move %TgtReplFile% %BakReplFile%
rem	type nul >%TgtReplFile%
rem	for /f "delims=" %%A in (%BakReplFile%) do (
rem	    set line=%%A
rem	    call :Rep1SubMTtoMD
rem	)
rem	exit /b
rem	:Rep1SubMTtoMD
rem	echo %line:/MT=/MD%>>%TgtReplFile%
rem	exit /b


:ReplaceMDtoMT
for /R %%i in (CMakeCache.txt) do (
  if exist %%i call :Rep1MDtoMT %%i
)
exit /b

:Rep1MDtoMT
..\bld_lib_bat\tiny_replstr.exe -x ++ "/MD" "/MT" -- %1
exit /b

rem	:Rep1MDtoMT
rem	set TgtReplFile=%1
rem	set BakReplFile=%1.bak
rem	if exist %BakReplFile% del %BakReplFile%
rem	move %TgtReplFile% %BakReplFile%
rem	type nul >%TgtReplFile%
rem	for /f "delims=" %%A in (%BakReplFile%) do (
rem	    set line=%%A
rem	    call :Rep1SubMDtoMT
rem	)
rem	exit /b
rem	:Rep1SubMDtoMT
rem	echo %line:/MD=/MT%>>%TgtReplFile%
rem	exit /b
