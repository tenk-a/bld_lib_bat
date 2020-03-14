set TgtDir=%1
set VcVer=%2
set HasX86=%3
set HasX64=%4

set SrcIncDir=%TgtDir%\boost
set DstIncDir=%CcInstallIncDir%\boost
if not exist "%DstIncDir%" mkdir "%DstIncDir%"
rmdir /S %DstIncDir%
xcopy %SrcIncDir% %DstIncDir% /R /Y /I /K

call :LibCopy x64
call :LibCopy Win32

goto :EOF

:LibCopy
set Arch=%1

set StageDir=
if /I "%CcTgtLibPathType%"=="D_VA"  set StageDir=%CcTgtLibDir%\%VcVer%\%Arch%
if /I "%CcTgtLibPathType%"=="D_AV"  set StageDir=%CcTgtLibDir%\%Arch%\%VcVer%
if /I "%CcTgtLibPathType%"=="J_VA"  set StageDir=%CcTgtLibDir%\%VcVer%_%Arch%
if /I "%CcTgtLibPathType%"=="J_AV"  set StageDir=%CcTgtLibDir%\%Arch%_%VcVer%
if "%StageDir%"=="" exit /b 1

set DstDir=
if /I "%CcInstallPathType%"=="D_VA"  set DstDir=%CcInstallLibDir%\%VcVer%\%Arch%
if /I "%CcInstallPathType%"=="D_VAR" set DstDir=%CcInstallLibDir%\%VcVer%\%Arch%
if /I "%CcInstallPathType%"=="D_VRA" set DstDir=%CcInstallLibDir%\%VcVer%\%Arch%
if /I "%CcInstallPathType%"=="D_RVA" set DstDir=%CcInstallLibDir%\%VcVer%\%Arch%

if /I "%CcInstallPathType%"=="D_AV"  set DstDir=%CcInstallLibDir%\%Arch%\%VcVer%
if /I "%CcInstallPathType%"=="D_AVR" set DstDir=%CcInstallLibDir%\%Arch%\%VcVer%
if /I "%CcInstallPathType%"=="D_ARV" set DstDir=%CcInstallLibDir%\%Arch%\%VcVer%
if /I "%CcInstallPathType%"=="D_RAV" set DstDir=%CcInstallLibDir%\%Arch%\%VcVer%

if /I "%CcInstallPathType%"=="J_VA"  set DstDir=%CcInstallLibDir%\%VcVer%_%Arch%
if /I "%CcInstallPathType%"=="J_VAR" set DstDir=%CcInstallLibDir%\%VcVer%_%Arch%
if /I "%CcInstallPathType%"=="J_VRA" set DstDir=%CcInstallLibDir%\%VcVer%_%Arch%
if /I "%CcInstallPathType%"=="J_RVA" set DstDir=%CcInstallLibDir%\%VcVer%_%Arch%

if /I "%CcInstallPathType%"=="J_AV"  set DstDir=%CcInstallLibDir%\%Arch%_%VcVer%
if /I "%CcInstallPathType%"=="J_AVR" set DstDir=%CcInstallLibDir%\%Arch%_%VcVer%
if /I "%CcInstallPathType%"=="J_ARV" set DstDir=%CcInstallLibDir%\%Arch%_%VcVer%
if /I "%CcInstallPathType%"=="J_RAV" set DstDir=%CcInstallLibDir%\%Arch%_%VcVer%

if "%DstDir%"=="" exit /b 1

xcopy %StageDir% %DstDir% /R /Y /I /K

exit /b

rem
rem
:END
popd
endlocal
