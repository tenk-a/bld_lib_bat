setlocal
set TgtDir=%1
set VcVer=%2
set HasX86=%3
set HasX64=%4
set first=

if not "%HasX64%"=="" (
  call :Copy1 x64 static
  call :Copy1 x64 rtdll
)

if not "%HasX86%"=="" (
  call :Copy1 Win32 static
  call :Copy1 Win32 rtdll
)
goto END

:Copy1
set Arch=%1
set Rt=%2
set SrcBaseDir=%TgtDir%\%CcTgtBldDir%\%VcVer%_%Arch%_%Rt%\install
if not exist %SrcBaseDir% exit /b /1

if "%first%"=="" (
  set first=1
  xcopy %SrcBaseDir%\include %CcInstallIncDir% /R /Y /I /K /E
)

set VsTag=
if /I "%VcVer%"=="vc142" set VsTag=vc16
if /I "%VcVer%"=="vc141" set VsTag=vc15
if /I "%VcVer%"=="vc140" set VsTag=vc14
if /I "%VcVer%"=="vc120" set VsTag=vc12
if /I "%VcVer%"=="vc110" set VsTag=vc11
if /I "%VcVer%"=="vc100" set VsTag=vc10
if "%VsTag%"=="" goto ERR

set SrcLibDir=%SrcBaseDir%
if "%Arch%"=="x64"   set SrcLibDir=%SrcLibDir%\x64
if "%Arch%"=="Win32" set SrcLibDir=%SrcLibDir%\x64
set SrcDllDir=%SrcLibDir%\%VsTag%\bin
set SrcLibDir=%SrcLibDir%\%VsTag%\staticlib

set StrLibPath=
call %CcBatDir%\sub\StrLibPath.bat %CcInstallPathType% %CcInstallLibDir% %VcVer% %Arch% %Rt%
set DstLibDir=%StrLibPath%
set DstLibDir=%DstLibDir:static=opencv_static%
set DstLibDir=%DstLibDir:rtdll=opencv%
set DstLibDir=%DstLibDir:dll=opencv_dll%
if not exist %DstLibDir% mkdir %DstLibDir%

xcopy %SrcLibDir% %DstLibDir% /R /Y /I /K /E

set StrLibPath=
call %CcBatDir%\sub\StrLibPath.bat %CcInstallPathType% %CcInstallDllDir% %VcVer% %Arch% %Rt% release
set DstDllDir=%StrLibPath%
xcopy %SrcDllDir% %DstDllDir% /R /Y /I /K /E

set StrLibPath=
call %CcBatDir%\sub\StrLibPath.bat %CcInstallPathType% %CcInstallDllDir% %VcVer% %Arch% %Rt% debug
set DstDllDir=%StrLibPath%
xcopy %SrcDllDir% %DstDllDir% /R /Y /I /K /E

exit /b

:END
endlocal
