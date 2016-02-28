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

if not "%1"=="" set "CcLibVorbisDir=%1"

if "%CcLibVorbisDir%"=="" (
  for /f %%i in ('dir /b /on /ad libvorbis*') do set CcLibVorbisDir=%%i
)

if "%CcLibVorbisDir%"=="" (
  echo ERROR: not found source directory
  goto END
)

if not exist %CcMiscIncDir%\ogg mkdir %CcMiscIncDir%\ogg
call :gen_header vorbisenc.h   %CcLibVorbisDir% >%CcMiscIncDir%\ogg\vorbisenc.h
call :gen_header codec.h       %CcLibVorbisDir% >%CcMiscIncDir%\ogg\codec.h
call :gen_header vorbisfile.h  %CcLibVorbisDir% >%CcMiscIncDir%\ogg\vorbisfile.h

set Arg=libcopy:%CD%\%CcMiscLibDir%
if "%CcNoRtStatic%"=="1" set Arg=%Arg% rtdll

cd %CcLibVorbisDir%
call ..\bld_lib_bat\setcc.bat %CcName% %CcLibArchX86%
call ..\bld_lib_bat\bld1_libvorbis.bat %CcLibArchX86% %Arg%
if "%CcHasX64%"=="1" (
  call ..\bld_lib_bat\setcc.bat %CcName% x64
  call ..\bld_lib_bat\bld1_libvorbis.bat x64 %Arg%
)
cd ..
goto END


:gen_header
echo /// %1 wrapper
echo #pragma once
echo #include "../../%2/include/vorbis/%1"
echo //#ifdef _MSC_VER
echo // #pragma comment(lib, "libvorbis_static.lib")
echo //#endif
exit /b

:END
cd bld_lib_bat
endlocal
