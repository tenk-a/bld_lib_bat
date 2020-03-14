setlocal

set TgtDir=%1
set VcVer=%2
set HasX86=%3
set HasX64=%4

call :HdrCopy

if "%HasX64%"=="x64" (
  call :LibCopy x64 static release
  call :LibCopy x64 static debug
  call :LibCopy x64 rtdll  release
  call :LibCopy x64 rtdll  debug
)
if "%HasX86%"=="Win32" (
  call :LibCopy Win32 static release
  call :LibCopy Win32 static debug
  call :LibCopy Win32 rtdll  release
  call :LibCopy Win32 rtdll  debug
)
:COPY_SKIP

goto END

:HdrCopy
set SrcIncDir=%TgtDir%
if not "%SrcIncSubDir%"=="" (
  set SrcIncDir=%SrcIncDir%\%SrcIncSubDir%
)
set DstIncDir=%CcInstallIncDir%
if not exist "%DstIncDir%" mkdir "%DstIncDir%"
if "%InstallIncSubDir%"=="" goto SKIP2
  set DstIncDir=%DstIncDir%\%InstallIncSubDir%
  if not exist "%DstIncDir%" mkdir "%DstIncDir%"
  if exist     "%DstIncDir%" del /q "%DstIncDir%\*.*"
:SKIP2
if not "%hdr1%"=="" copy %SrcIncDir%\%hdr1% %DstIncDir%\
if not "%hdr2%"=="" copy %SrcIncDir%\%hdr2% %DstIncDir%\
if not "%hdr3%"=="" copy %SrcIncDir%\%hdr3% %DstIncDir%\
if not "%hdr4%"=="" copy %SrcIncDir%\%hdr4% %DstIncDir%\
if not "%hdr5%"=="" copy %SrcIncDir%\%hdr5% %DstIncDir%\
if not "%hdr6%"=="" copy %SrcIncDir%\%hdr6% %DstIncDir%\
if not "%hdr7%"=="" copy %SrcIncDir%\%hdr7% %DstIncDir%\
if not "%hdr8%"=="" copy %SrcIncDir%\%hdr8% %DstIncDir%\
if not "%hdr9%"=="" copy %SrcIncDir%\%hdr9% %DstIncDir%\
exit /b


:LibCopy
set Arch=%1
set Rt=%2
set Conf=%3

set SlnDir=
if "%VcVer%"=="vc142" set SlnDir=VS2019
if "%VcVer%"=="vc141" set SlnDir=VS2017
if "%VcVer%"=="vc140" set SlnDir=VS2015
if "%VcVer%"=="vc120" set SlnDir=VS2013
if "%VcVer%"=="vc110" set SlnDir=VS2012
if "%VcVer%"=="vc100" set SlnDir=VS2010
if "%VcVer%"=="vc90"  set SlnDir=VS2008
if "%VcVer%"=="vc80"  set SlnDir=VS2005
if "%VcVer%"=="vc71"  set SlnDir=VS2003

if "%Rt%"=="rtdll" set SlnDir=%SlnDir%_rtdll

set SrcLibDir=%TgtDir%\win32\%SlnDir%\%Arch%\%Conf%
if not exist %SrcLibDir% exit /b 1

set StrLibPath=
call sub\StrLibPath.bat %CcInstallPathType% %CcInstallLibDir% %VcVer% %Arch% %Rt% %Conf%
set DstLibDir=%StrLibPath%
if "%DstLibDir%"=="" (
  echo [ERROR] No %%CcInstallPathType%%
  exit /b
)
if not "%InstallLibSubDir%"=="" set DstLibDir=%DstLibDir%\%InstallLibSubDir%
if not exist %DstLibDir% mkdir %DstLibDir%

if exist %SrcLibDir%\libogg.lib copy /b %SrcLibDir%\libogg.lib %DstLibDir%\

exit /b

:END
endlocal
