@echo off
rem This batch-file license: boost software license version 1.0
setlocal
call libs_config.bat
cd ..

if not exist %CcMiscIncDir% mkdir %CcMiscIncDir%
if not exist %CcMiscLibDir% mkdir %CcMiscLibDir%

if not "%1"=="" set "CcGlfwDir=%1"

if "%CcGlfwDir%"=="" (
  for /f %%i in ('dir /b /on /ad glfw*') do set CcGlfwDir=%%i
)

if "%CcGlfwDir%"=="" (
  echo ERROR: not found source directory
  goto END
)

call :gen_header glfw3.h       ../../%CcGlfwDir%/include/glfw glfw3.lib %CcMiscIncDir%\glfw
call :gen_header glfw3native.h ../../%CcGlfwDir%/include/glfw glfw3.lib %CcMiscIncDir%\glfw

set Arg=
set Arg=%Arg% libcopy:%CD%\%CcMiscLibDir%
set Arg=%Arg% LibDir:lib
set Arg=%Arg% LibPrefix:%CcLibPrefix%
set Arg=%Arg% LibRtSta:%CcLibStrStatic%
set Arg=%Arg% LibRtDll:%CcLibStrRtDll%
set Arg=%Arg% LibRel:%CcLibStrRelease%
set Arg=%Arg% LibDbg:%CcLibStrDebug%

if "%CcNoRtStatic%"=="1" set Arg=%Arg% rtdll

cd %CcGlfwDir%
call ..\bld_lib_bat\setcc.bat %CcName% %CcLibArchX86%
call ..\bld_lib_bat\bld1_glfw.bat %CcLibArchX86% %Arg%
if "%CcHasX64%"=="1" (
  call ..\bld_lib_bat\setcc.bat %CcName% x64
  call ..\bld_lib_bat\bld1_glfw.bat x64 %Arg%
)
cd ..
goto END

:gen_header
if not exist %4 mkdir %4
call :gen_header_print %1 %2 %3 >%4\%1
exit /b
:gen_header_print
echo /// %1 wrapper
echo #pragma once
echo #include "%2/%1"
echo #ifdef _MSC_VER
echo  #pragma comment(lib, "%3")
echo #endif
exit /b

:END
cd bld_lib_bat
endlocal
