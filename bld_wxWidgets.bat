@echo off
rem This batch-file license: boost software license version 1.0
setlocal
call libs_config.bat
cd ..

if not "%1"=="" set "CcWxWidgetsDir=%1"

if "%CcWxWidgetsDir%"=="" (
  for /f %%i in ('dir /b /on /ad wxWidgets*') do set CcWxWidgetsDir=%%i
)

if "%CcWxWidgetsDir%"=="" (
  echo ERROR: not found source directory
  goto END
)

set Arg=
if "%CcNoRtStatic%"=="1" set Arg=%Arg% rtdll dll

cd %CcWxWidgetsDir%
call ..\bld_lib_bat\setcc.bat %CcName% %CcLibArchX86%
call ..\bld_lib_bat\bld1_wxWidgets.bat %CcLibArchX86% %Arg%
if "%CcHasX64%"=="1" (
  call ..\bld_lib_bat\setcc.bat %CcName% x64
  call ..\bld_lib_bat\bld1_wxWidgets.bat x64 %Arg%
)
cd ..

:END
cd bld_lib_bat
endlocal
