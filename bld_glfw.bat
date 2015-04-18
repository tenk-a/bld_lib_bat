@echo off
rem This batch-file license: boost software license version 1.0
setlocal
call libs_config.bat
cd ..

if not exist %CcMiscIncDir% mkdir %CcMiscIncDir%
if not exist %CcMiscLibDir% mkdir %CcMiscLibDir%

if not "%1"=="" set "CcGlfwDir=%1"

if "%CcGlfwDir%"=="" (
  for /f %%i in ('dir /b /on /ad glfw-*') do set CcGlfwDir=%%i
)

if "%CcGlfwDir%"=="" (
  echo ERROR: not found source directory
  goto END
)

if not exist %CcMiscIncDir%\glfw mkdir %CcMiscIncDir%\glfw
call :gen_header glfw3.h       %CcGlfwDir% >%CcMiscIncDir%\glfw\glfw3.h
call :gen_header glfw3native.h %CcGlfwDir% >%CcMiscIncDir%\glfw\glfw3native.h

set Arg=libcopy:%CD%\%CcMiscLibDir%
if "%CcNoRtStatic%"=="1" set Arg=%Arg% rtdll

cd %CcGlfwDir%
call ..\bld_lib_bat\setcc.bat %CcName% x86
call ..\bld_lib_bat\bld1_glfw.bat x86 %Arg%
if "%CcHasX64%"=="1" (
  call ..\bld_lib_bat\setcc.bat %CcName% x64
  call ..\bld_lib_bat\bld1_glfw.bat x64 %Arg%
)
cd ..
goto END


:gen_header
echo /// %1 wrapper
echo #pragma once
echo #include "../../%2/include/glfw/%1"
echo #ifdef _MSC_VER
echo  #pragma comment(lib, "glfw3.lib")
echo #endif
exit /b

:END
cd bld_lib_bat
endlocal
