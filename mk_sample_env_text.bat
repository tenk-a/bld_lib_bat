@echo off
rem This batch-file license: boost software license version 1.0

set LibRoot=%CD%
set "LibDirsX86Rel="
set "LibDirsX86Dbg="
set "LibDirsX64Rel="
set "LibDirsX64Dbg="
set "LibRtDllDirsX86Rel="
set "LibRtDllDirsX86Dbg="
set "LibRtDllDirsX64Rel="
set "LibRtDllDirsX64Dbg="
set "LibDllDirsX86Rel="
set "LibDllDirsX86Dbg="
set "LibDllDirsX64Rel="
set "LibDllDirsX64Dbg="

for %%i in (bld_*.bat) do call :One %%i

goto END

:One
set ARG=%1
set Base=%ARG:~4,-4%

for /f %%i in ('dir /b /on /ad %Base%*') do set Target=%%i

if /I "%base%"=="boost"         goto OneBoost
if /I "%base%"=="wxWidgets"     goto OneWxWidgets
if /I "%base%"=="zlib"          goto OneZlibType
if /I "%base%"=="bzip2"         goto OneZlibType
if /I "%base%"=="jpeg"          goto OneZlibType
if /I "%base%"=="libjpeg-turbo" goto OneZlibType
goto ERR_UNKOWN

:OneBoost
  set LibDir1=%Target%\stage
  set LibDir1X86Rel=%LibDir1%\vc_x86\lib
  set LibDir1X86Dbg=%LibDir1%\vc_x86\lib
  set LibDir1X64Rel=%LibDir1%\vc_x64\lib
  set LibDir1X64Dbg=%LibDir1%\vc_x64\lib
  set LibRtDllDir1X86Rel=%LibDir1X86Rel%
  set LibRtDllDir1X86Dbg=%LibDir1X86Dbg%
  set LibRtDllDir1X64Rel=%LibDir1X64Rel%
  set LibRtDllDir1X64Dbg=%LibDir1X64Dbg%
  set LibDllDir1X86Rel=%LibDir1X86Rel%
  set LibDllDir1X86Dbg=%LibDir1X86Dbg%
  set LibDllDir1X64Rel=%LibDir1X64Rel%
  set LibDllDir1X64Dbg=%LibDir1X64Dbg%
  goto OneEnd

:OneWxWidgets
  set LibDir1=%Target%\lib
  set LibDir1X86Rel=%LibDir1%\vc_lib
  set LibDir1X86Dbg=%LibDir1%\vc_lib
  set LibDir1X64Rel=%LibDir1%\vc_x64_lib
  set LibDir1X64Dbg=%LibDir1%\vc_x64_lib
  set LibRtDllDir1X86Rel=%LibDir1%\vc_lib_rtdll
  set LibRtDllDir1X86Dbg=%LibDir1%\vc_lib_rtdll
  set LibRtDllDir1X64Rel=%LibDir1%\vc_x64_lib_rtdll
  set LibRtDllDir1X64Dbg=%LibDir1%\vc_x64_lib_rtdll
  set LibDllDir1X86Rel=%LibDir1%\vc_dll
  set LibDllDir1X86Dbg=%LibDir1%\vc_dll
  set LibDllDir1X64Rel=%LibDir1%\vc_x64_dll
  set LibDllDir1X64Dbg=%LibDir1%\vc_x64_dll
  goto OneEnd

:OneZlibType
  set LibDir1=%Target%\lib
  set LibDir1X86Rel=%LibDir1%\vc_x86_release
  set LibDir1X86Dbg=%LibDir1%\vc_x86_debug
  set LibDir1X64Rel=%LibDir1%\vc_x64_release
  set LibDir1X64Dbg=%LibDir1%\vc_x64_debug
  set LibRtDllDir1X86Rel=%LibDir1X86Rel%_rtdll
  set LibRtDllDir1X86Dbg=%LibDir1X86Dbg%_rtdll
  set LibRtDllDir1X64Rel=%LibDir1X64Rel%_rtdll
  set LibRtDllDir1X64Dbg=%LibDir1X64Dbg%_rtdll
  set LibDllDir1X86Rel=%LibDir1X86Rel%_rtdll
  set LibDllDir1X86Dbg=%LibDir1X86Dbg%_rtdll
  set LibDllDir1X64Rel=%LibDir1X64Rel%_rtdll
  set LibDllDir1X64Dbg=%LibDir1X64Dbg%_rtdll
  goto OneEnd

:OneEnd

set "LibDirsX86Rel=%LibRoot%\%LibDir1X86Rel%;%LibDirsX86Rel%"
set "LibDirsX86Dbg=%LibRoot%\%LibDir1X86Dbg%;%LibDirsX86Dbg%"
set "LibDirsX64Rel=%LibRoot%\%LibDir1X64Rel%;%LibDirsX64Rel%"
set "LibDirsX64Dbg=%LibRoot%\%LibDir1X64Dbg%;%LibDirsX64Dbg%"
set "LibRtDllDirsX86Rel=%LibRoot%\%LibDllDir1X86Rel%;%LibRtDllDirsX86Rel%"
set "LibRtDllDirsX86Dbg=%LibRoot%\%LibDllDir1X86Dbg%;%LibRtDllDirsX86Dbg%"
set "LibRtDllDirsX64Rel=%LibRoot%\%LibDllDir1X64Rel%;%LibRtDllDirsX64Rel%"
set "LibRtDllDirsX64Dbg=%LibRoot%\%LibDllDir1X64Dbg%;%LibRtDllDirsX64Dbg%"
set "LibDllDirsX86Rel=%LibRoot%\%LibDllDir1X86Rel%;%LibDllDirsX86Rel%"
set "LibDllDirsX86Dbg=%LibRoot%\%LibDllDir1X86Dbg%;%LibDllDirsX86Dbg%"
set "LibDllDirsX64Rel=%LibRoot%\%LibDllDir1X64Rel%;%LibDllDirsX64Rel%"
set "LibDllDirsX64Dbg=%LibRoot%\%LibDllDir1X64Dbg%;%LibDllDirsX64Dbg%"

exit /b


:ERR_UNKOWN
  echo -----------------------
  echo ERROR: unkown bld batch: %ARG%
  echo -----------------------

:END
set ARG=
set Base=
set LibDir1=
set Target=
echo LibDirsX86Rel=%LibDirsX86Rel%
echo LibDirsX86Dbg=%LibDirsX86Dbg%
echo LibDirsX64Rel=%LibDirsX64Rel%
echo LibDirsX64Dbg=%LibDirsX64Dbg%
echo LibRtDllDirsX86Rel=%LibRtDllDirsX86Rel%
echo LibRtDllDirsX86Dbg=%LibRtDllDirsX86Dbg%
echo LibRtDllDirsX64Rel=%LibRtDllDirsX64Rel%
echo LibRtDllDirsX64Dbg=%LibRtDllDirsX64Dbg%
echo LibDllDirsX86Rel=%LibDllDirsX86Rel%
echo LibDllDirsX86Dbg=%LibDllDirsX86Dbg%
echo LibDllDirsX64Rel=%LibDllDirsX64Rel%
echo LibDllDirsX64Dbg=%LibDllDirsX64Dbg%
