rem @echo off
rem This batch-file license: boost software license version 1.0
setlocal

set VcVer=%1
shift
set Arch=%1
shift

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
set CleanMode=

:ARG_LOOP
  set ARG=%1
  if "%1"=="" goto ARG_LOOP_EXIT

  if /I "%1"=="static"   set HasRtSta=S
  if /I "%1"=="rtsta"    set HasRtSta=S
  if /I "%1"=="rtdll"    set HasRtDll=L

  if /I "%1"=="release"  set HasRel=r
  if /I "%1"=="debug"    set HasDbg=d

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

if "%Arch%"=="" set Arch=Win32

if not exist bld mkdir bld


if "%CleanMode%"=="1" (
  pushd bld
  call :Clean
  popd
  goto :EOF
)

if "%HasRtSta%%HasRtDll%"=="" (
  set HasRtSta=S
  set HasRtDll=L
)
if "%HasRel%%HasDbg%"=="" (
  set HasRel=r
  set HasDbg=d
)

if "%LibDir%"=="" set LibDir=lib

pushd bld
if "%HasRtSta%%HasRel%"=="Sr" call :Bld1 rtsta release %StrPrefix%%Arch%%StrRtSta%%StrRel%
if "%HasRtSta%%HasDbg%"=="Sd" call :Bld1 rtsta debug   %StrPrefix%%Arch%%StrRtSta%%StrDbg%
if "%HasRtDll%%HasRel%"=="Lr" call :Bld1 rtdll release %StrPrefix%%Arch%%StrRtDll%%StrRel%
if "%HasRtDll%%HasDbg%"=="Ld" call :Bld1 rtdll debug   %StrPrefix%%Arch%%StrRtDll%%StrDbg%
popd

goto END


:Bld1
set RtType=%1
set BldType=%2
set Target=%3

if not exist %Target% mkdir %Target%

pushd %Target%
set DstBaseDir=..\..

call :Clean

set ADD_CMAKE_OPTS=
if %RtType%==rtdll (
    set ADD_CMAKE_OPTS=-DWITH_CRT_DLL=true
) else (
    set ADD_CMAKE_OPTS=-DWITH_CRT_DLL=false
)
CMake -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=%BldType% %ADD_CMAKE_OPTS% %DstBaseDir%\
if errorlevel 1 (
  popd
  exit /b
)

rem if %RtType%==rtdll (
rem   call :ReplaceMTtoMD
rem )
if %RtType%==rtsta (
    call :ReplaceMDtoMT
)

nmake
if errorlevel 1 (
  popd
  exit /b
)

set DstLibDir=%DstBaseDir%\%LibDir%
if not exist %DstLibDir% mkdir %DstLibDir%
set DstLibDir=%DstLibDir%\%Target%

set DstExeDir=%DstBaseDir%\exe
if not exist %DstExeDir% mkdir %DstExeDir%
set DstExeDir=%DstExeDir%\%Target%

del *.obj *.exp *.ilk *.res *.resource.txt *.manifest

if not exist %DstBaseDir%\jconfig.h    copy jconfig.h    %DstBaseDir%\
if not exist %DstBaseDir%\jconfigint.h copy jconfigint.h %DstBaseDir%\

if exist *.lib move *.lib %DstLibDir%\
if exist *.dll move *.dll %DstLibDir%\
if exist turbojpeg.pdb move turbojpeg.pdb %DstLibDir%\
if exist sharedlib\*.lib move sharedlib\*.lib %DstLibDir%\
if exist sharedlib\*.dll move sharedlib\*.dll %DstLibDir%\
if exist sharedlib\jpeg.pdb move sharedlib\jpeg.pdb %DstLibDir%\

if exist *.exe move *.exe %DstExeDir%\
if exist *.pdb move *.pdb %DstExeDir%\
if exist sharedlib\*.exe move sharedlib\*.exe %DstExeDir%\
if exist sharedlib\*.pdb move sharedlib\*.pdb %DstExeDir%\

popd

exit /b


:Clean
del /S /F /Q .\*.*
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

:END
endlocal
