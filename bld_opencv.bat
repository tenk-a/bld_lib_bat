rem @echo off
rem This batch-file license: boost software license version 1.0
setlocal
call libs_config.bat
cd ..

set Compl=
if /I "%1"=="vc140" set Compl=vc140
if /I "%1"=="vc120" set Compl=vc120
if /I "%1"=="vc110" set Compl=vc110
if /I "%1"=="vc100" set Compl=vc100
if /I "%1"=="vc90"  set Compl=vc90
if /I "%1"=="vc80"  set Compl=vc80
if not "%Compl%"=="" (
  set CcLibPrefix=%Compl%_
  shift
) else (
  set Compl=%CcName%
)

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
if not exist %CcOpenCvDir% (
  echo ERROR: not found source directory '%CcOpenCvDir%'
  goto END
)

cd %CcOpenCvDir%
set Arg=LibPrefix:%CcLibPrefix% %EnableCuda%
set Arg=%Arg% LibPrefix:%CcLibPrefix%
if "%CcNoRtStatic%"=="1" set Arg=%Arg% rtdll

call ..\bld_lib_bat\setcc.bat       %Compl% %CcLibArchX86%
call ..\bld_lib_bat\bld1_opencv.bat %Compl% %CcLibArchX86% %Arg%
if "%CcHasX64%"=="1" (
  call ..\bld_lib_bat\setcc.bat       %Compl% x64
  call ..\bld_lib_bat\bld1_opencv.bat %Compl% x64 %Arg%
)
cd ..

:END
cd bld_lib_bat
endlocal
