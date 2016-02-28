@echo off
rem This batch-file license: boost software license version 1.0
setlocal
call libs_config.bat
cd ..

if not "%1"=="" set CcBoostDir=%1

if "%CcBoostDir%"=="" (
  for /f %%i in ('dir /b /on /ad boost*') do set CcBoostDir=%%i
)

if "%CcBoostDir%"=="" (
  echo ERROR: not found source directory
  goto END
)

if "%CcZlibDir%"=="" (
  for /f %%i in ('dir /b /on /ad zlib*') do set CcZlibDir=%CD%\%%i
)
if "%CcBzip2Dir%"=="" (
  for /f %%i in ('dir /b /on /ad bzip2*') do set CcBzip2Dir=%CD%\%%i
)

cd %CcBoostDir%
set Arg=zlib:%CcZlibDir% bzip2:%CcBzip2Dir% LibPrefix:%CcLibPrefix%
call ..\bld_lib_bat\setcc.bat      %CcName% %CcLibArchX86%
call ..\bld_lib_bat\bld1_boost.bat %CcName% %CcLibArchX86% %Arg%
if "%CcHasX64%"=="1" (
  call ..\bld_lib_bat\setcc.bat      %CcName% x64
  call ..\bld_lib_bat\bld1_boost.bat %CcName% x64 %Arg%
)
cd ..

:END
cd bld_lib_bat
endlocal
