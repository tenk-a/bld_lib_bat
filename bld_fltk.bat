rem @echo off
rem This batch-file license: boost software license version 1.0
setlocal
call libs_config.bat

if not exist tiny_replstr.exe (
  call setcc.bat %CcName% x86
  call gen_replstr.bat
)

cd ..

if not exist %CcMiscIncDir% mkdir %CcMiscIncDir%
if not exist %CcMiscLibDir% mkdir %CcMiscLibDir%

if not "%1"=="" set "CcFltkDir=%1"

if "%CcFltkDir%"=="" (
  for /f %%i in ('dir /b /on /ad fltk*') do set CcFltkDir=%%i
)

if "%CcFltkDir%"=="" (
  echo ERROR: not found source directory
  goto END
)

set Arg=
if "%CcNoRtStatic%"=="1" set Arg=%Arg% rtdll

cd %CcFltkDir%
call ..\bld_lib_bat\setcc.bat %CcName% x86
call ..\bld_lib_bat\bld1_fltk.bat x86 %Arg%
if "%CcHasX64%"=="1" (
  call ..\bld_lib_bat\setcc.bat %CcName% x64
  call ..\bld_lib_bat\bld1_fltk.bat x64 %Arg%
)
cd ..

cd bld_lib_bat
endlocal
