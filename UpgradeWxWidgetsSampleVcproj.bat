@echo off
rem generalte vc10-14.1 vcxproj for wxWidgets 3.0 Samples
setlocal

set VcName=
if "%CcName%"=="" (
  if /I not "%PATH:Microsoft Visual Studio\2017=%"=="%PATH%" set VcName=vc141
  if /I not "%PATH:Microsoft Visual Studio 14.0=%"=="%PATH%" set VcName=vc140
  if /I not "%PATH:Microsoft Visual Studio 13.0=%"=="%PATH%" set VcName=vc130
  if /I not "%PATH:Microsoft Visual Studio 12.0=%"=="%PATH%" set VcName=vc120
  if /I not "%PATH:Microsoft Visual Studio 11.0=%"=="%PATH%" set VcName=vc110
  if /I not "%PATH:Microsoft Visual Studio 10.0=%"=="%PATH%" set VcName=vc100
)
if "%VcName%"=="" (
  echo ERROR: not found vc100-141 path.
  goto :EOF
)

pushd Samples

for /R /D %%j in (*) do (
  cd %%j
  call :VcUpgrade *_vc9* *_%VcName%*
  cd ..
)

popd
goto :EOF

:VcUpgrade
set SRC_PROJFILE=%1
set DST_PROJFILE=%2
if exist %DST_PROJFILE%.vcxproj goto :EOF
if not exist %SRC_PROJFILE%.vcproj goto :EOF
copy %SRC_PROJFILE%.vcproj %DST_PROJFILE%.vcproj
for %%i in (%DST_PROJFILE%.vcproj) do (
  devenv /Upgrade %%i
  if exist %%i del %%~ni.vcproj
  if exist UpgradeLog.htm del UpgradeLog.htm
  if exist Backup (
    del /S /F /Q Backup\*.*
    rmdir Backup*
  )
)
exit /b
