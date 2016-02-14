rem @echo off
rem This batch-file license: boost software license version 1.0
setlocal
call libs_config.bat
cd ..

if not exist %CcMiscIncDir% mkdir %CcMiscIncDir%
if not exist %CcMiscLibDir% mkdir %CcMiscLibDir%

if not "%1"=="" set "CcLibHaruDir=%1"

if "%CcLibHaruDir%"=="" (
  for /f %%i in ('dir /b /on /ad libharu*') do set CcLibHaruDir=%%i
)

if "%CcLibHaruDir%"=="" (
  echo ERROR: not found source directory
  goto END
)

if not exist %CcMiscIncDir%\libharu mkdir %CcMiscIncDir%\libharu
for /f %%i in ('dir /b /on %CcLibHaruDir%\include\*.h') do call :gen_header %%~nxi
for /f %%i in ('dir /b /on %CcLibHaruDir%\win32\include\*.h') do call :gen_header2 %%~nxi

set Arg=libcopy:%CD%\%CcMiscLibDir%
if "%CcNoRtStatic%"=="1" set Arg=%Arg% rtdll

cd %CcLibHaruDir%
call ..\bld_lib_bat\setcc.bat %CcName% x86
call ..\bld_lib_bat\bld1_libharu.bat   x86 %Arg% ZlibDir:misc PngDir:misc
if "%CcHasX64%"=="1" (
  call ..\bld_lib_bat\setcc.bat %CcName% x64
  call ..\bld_lib_bat\bld1_libharu.bat x64 %Arg% ZlibDir:misc PngDir:misc
)
cd ..
goto :END


:gen_header
echo /// %1 wrapper >%CcMiscIncDir%\libharu\%1
echo #pragma once >>%CcMiscIncDir%\libharu\%1
echo #include "../../%CcLibHaruDir%/include/%1" >>%CcMiscIncDir%\libharu\%1
echo #ifdef _MSC_VER >>%CcMiscIncDir%\libharu\%1
echo   #pragma comment(lib, "libhpdf.lib") >>%CcMiscIncDir%\libharu\%1
echo #endif >>%CcMiscIncDir%\libharu\%1
exit /b

:gen_header2
echo /// %1 wrapper >%CcMiscIncDir%\libharu\%1
echo #pragma once >>%CcMiscIncDir%\libharu\%1
echo #include "../../%CcLibHaruDir%/win32/include/%1" >>%CcMiscIncDir%\libharu\%1
echo #ifdef _MSC_VER >>%CcMiscIncDir%\libharu\%1
echo   #pragma comment(lib, "libhpdf.lib") >>%CcMiscIncDir%\libharu\%1
echo #endif >>%CcMiscIncDir%\libharu\%1
exit /b


:END
cd bld_lib_bat
endlocal
