rem @echo off
rem generalte vc10-14.2 vcxproj for wxWidgets 3.0 Samples
setlocal

set VcVer=%1
if "%VcVer%"=="" goto ERR

pushd %~dp0
pushd ..
call bld_config.bat
pushd %CcLibsRoot%
set CcLibsRoot=%CD%
popd
call setcc.bat %VcVer%
popd
call 01_init.bat

pushd %CcLibsRoot%\%TgtName%\Samples

for /R /D %%j in (*) do (
  cd %%j
  call :VcUpgrade *_vc9* *_%VcVer%*
  cd ..
)

popd
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

:ERR
echo ERROR: for vc10 or later
exit /b 1
