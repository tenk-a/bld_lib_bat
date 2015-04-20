rem @echo off
rem generalte vc11-12 vcxproj from fltk/IDE/VisualC2010
setlocal

set VcDirName=
if "%CcName%"=="" (
  if /I not "%PATH:Microsoft Visual Studio 13.0=%"=="%PATH%" (
    set VcDirName=VisualC2015
  )
  if /I not "%PATH:Microsoft Visual Studio 12.0=%"=="%PATH%" (
    set VcDirName=VisualC2013
  )
  if /I not "%PATH:Microsoft Visual Studio 11.0=%"=="%PATH%" (
    set VcDirName=VisualC2012
  )
)
if "%VcDirName%"=="" (
  echo ERROR: not found vc11-12 path.
  goto :EOF
)


pushd IDE

if exist %VcDirName% goto :EOF
mkdir %VcDirName%
copy VisualC2010\*.* %VcDirName%\

pushd %VcDirName%

devenv /Upgrade fltk.sln
if exist UpgradeLog.htm del UpgradeLog.htm
if exist Backup (
  del /S /F /Q Backup\*.*
  rmdir Backup*
)
for /R /D %%i in (*.*) do (
  rmdir /S /Q %%i
)
attrib -R -S -H *.suo
del *.suo

popd

popd
