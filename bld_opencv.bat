rem @echo off
rem This batch-file license: boost software license version 1.0
setlocal
call libs_config.bat
cd ..

set EnableCuda=
if /I "%1"=="-EnableCuda" (
  set EnableCuda=EnableCuda
  shift
)

if not "%1"=="" set CcOpenCvDir=%1

if "%CcOpenCvDir%"=="" (
  for /f %%i in ('dir /b /on /ad opencv*') do set CcOpenCvDir=%%i
)

if "%CcOpenCvDir%"=="" (
  echo ERROR: not found source directory
  goto END
)

cd %CcOpenCvDir%
set Arg=LibPrefix:%CcLibPrefix% %EnableCuda%
call ..\bld_lib_bat\setcc.bat       %CcName% %CcLibArchX86%
call ..\bld_lib_bat\bld1_opencv.bat %CcName% %CcLibArchX86% %Arg%
if "%CcHasX64%"=="1" (
  call ..\bld_lib_bat\setcc.bat       %CcName% x64
  call ..\bld_lib_bat\bld1_opencv.bat %CcName% x64 %Arg%
)
cd ..

:END
cd bld_lib_bat
endlocal
