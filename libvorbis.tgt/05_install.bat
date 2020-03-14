setlocal

set TgtDir=%1
set VcVer=%2
set HasX86=%3
set HasX64=%4

call :HdrCopy

if "%HasX64%"=="x64" (
  call :LibCopy x64 rtsta release
  call :LibCopy x64 rtsta debug
  call :LibCopy x64 rtdll release
  call :LibCopy x64 rtdll debug
)
if "%HasX86%"=="Win32" (
  call :LibCopy Win32 rtsta release
  call :LibCopy Win32 rtsta debug
  call :LibCopy Win32 rtdll release
  call :LibCopy Win32 rtdll debug
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

if "%Conf%"=="rel" set Conf=release
if "%Conf%"=="dbg" set Conf=debug

set RtStr=
if "%Rt%"=="rtsta" set RtStr=%CcStrStatic%
if "%Rt%"=="rtdll" set RtStr=%CcStrRtDll%


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


if "%RtType%"=="static" (
  if exist %SrcLibDir%\libvorbis_static.lib 	copy %SrcLibDir%\libvorbis_static.lib %DstLibDir%\
  if exist %SrcLibDir%\libvorbisfile_static.lib copy %SrcLibDir%\libvorbisfile_static.lib %DstLibDir%\
)

if "%RtType%"=="rtdll" (
  if exist %SrcLibDir%\libvorbis_rtdll.lib 	copy %SrcLibDir%\libvorbis_rtdll.lib %DstLibDir%\libvorbis_static.lib
  if exist %SrcLibDir%\libvorbis_rtdll.lib 	copy %SrcLibDir%\libvorbis_rtdll.lib %DstLibDir%\libvorbis.lib
  if exist %SrcLibDir%\libvorbisfile_rtdll.lib  copy %SrcLibDir%\libvorbisfile_rtdll.lib %DstLibDir%\libvorbisfile_static.lib
  if exist %SrcLibDir%\libvorbisfile_rtdll.lib  copy %SrcLibDir%\libvorbisfile_rtdll.lib %DstLibDir%\libvorbisfile.lib
  rem if exist %SrcLibDir%\libvorbis_rtdll.lib 	copy %SrcLibDir%\libvorbis_rtdll.lib %DstLibDir%\
)

rem for dll
if not "%RtType%"=="dll" exit /b

if exist %SrcLibDir%\libvorbis.lib 	copy %SrcLibDir%\libvorbis.lib %DstLibDir%\
rem if exist %SrcLibDir%\libvorbis.dll 	copy %SrcLibDir%\libvorbis.dll %DstLibDir%\
rem if exist %SrcLibDir%\libvorbis.pdb 	copy %SrcLibDir%\libvorbis.pdb %DstLibDir%\

call sub\StrLibPath.bat %CcInstallPathType% %CcInstallDllDir% %VcVer% %Arch% %Rt% %Conf%
set DstDllDir=%StrLibPath%
if not exist %DstDllDir% mkdir %DstDllDir%

if exist %SrcLibDir%\libvorbis.dll 	copy %SrcLibDir%\libvorbis.dll %DstDllDir%\
if exist %SrcLibDir%\libvorbis.pdb 	copy %SrcLibDir%\libvorbis.pdb %DstDllDir%\
exit /b


:END
endlocal
