set TgtDir=%1
set VcVer=%2
set HasX86=%3
set HasX64=%4

set NativeDir=%TgtDir%\script\Microsoft.Web.WebView2.0.8.355\build\native
if not exist "%CcInstallIncDir%" mkdir "%CcInstallIncDir%"
copy %TgtDir%\webview.h %CcInstallIncDir%\
pause
rem copy %TgtDir%\script\WebView2.h %CcInstallIncDir%\
copy %NativeDir%\include\WebView2.h %CcInstallIncDir%\
pause

if not "%HasX64%"=="-" call :LibCopy x64   x64
if not "%HasX86%"=="-" call :LibCopy Win32 x86

goto :EOF

:LibCopy
call :LibCopy1 %1 %2 static release
call :LibCopy1 %1 %2 static debug
call :LibCopy1 %1 %2 rtdll  release
call :LibCopy1 %1 %2 rtdll  debug
exit /b

:LibCopy1
set Arch=%1
set Cpu=%2
set Rt=%3
set Conf=%4

set StrLibPath=
call %CcBatDir%\sub\StrLibPath.bat %CcInstallPathType% %CcInstallLibDir% %VcVer% %Arch% %Rt% %Conf%
set DstLibDir=%StrLibPath%

if not exist %DstLibDir% mkdir %DstLibDir%
copy %NativeDir%\%Cpu%\WebView2Loader.dll.lib %DstLibDir%\
pause
copy %NativeDir%\%Cpu%\WebView2Guid.lib       %DstLibDir%\

set StrLibPath=
call %CcBatDir%\sub\StrLibPath.bat %CcInstallPathType% %CcInstallDllDir% %VcVer% %Arch% %Rt% %Conf%
set DstDllDir=%StrLibPath%

if not exist %DstDllDir% mkdir %DstDllDir%
copy %NativeDir%\%Cpu%\WebView2Loader.dll %DstDllDir%\

exit /b
