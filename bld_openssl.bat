@echo off
rem This batch-file license: boost software license version 1.0
setlocal
call libs_config.bat

if not exist tiny_replstr.exe (
  call setcc.bat %CcName% %CcLibArchX86%
  call gen_replstr.bat
)

cd ..

if not exist %CcMiscIncDir% mkdir %CcMiscIncDir%
if not exist %CcMiscLibDir% mkdir %CcMiscLibDir%

if not "%1"=="" set "CcOpenSslDir=%1"

if "%CcOpenSslDir%"=="" (
  for /f %%i in ('dir /b /on /ad openssl*') do set CcOpenSslDir=%%i
)

if "%CcOpenSslDir%"=="" (
  echo ERROR: not found source directory
  goto END
)

if not exist %CcMiscIncDir%\openssl mkdir %CcMiscIncDir%\openssl
del /q %CcMiscIncDir%\openssl\*.*
copy %CcOpenSslDir%\include\openssl\*.h %CcMiscIncDir%\openssl\

set Arg=libcopy:%CD%\%CcMiscLibDir%
if "%CcNoRtStatic%"=="1" set Arg=%Arg% rtdll

cd %CcOpenSslDir%
call ..\bld_lib_bat\setcc.bat %CcName% %CcLibArchX86%
call ..\bld_lib_bat\bld1_openssl.bat %CcLibArchX86% %Arg%
if "%CcHasX64%"=="1" (
  call ..\bld_lib_bat\setcc.bat %CcName% x64
  call ..\bld_lib_bat\bld1_openssl.bat x64 %Arg%
)
cd ..

cd bld_lib_bat
endlocal
