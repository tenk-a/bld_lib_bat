mkdir %CcLibsRoot%\%TgtDir%\sources
pushd %CcLibsRoot%\%TgtDir%\sources
if "%GitBranch%"=="" (
  git clone https://github.com/opencv/opencv.git .
) else (
  git clone -b %GitBranch% https://github.com/opencv/opencv.git .
)
if not "%GitTag%"=="" (
  git checkout -b %GitTag% refs/tags/%GitTag%
)
pause
popd

mkdir %CcLibsRoot%\%TgtDir%\opencv_contrib
pushd %CcLibsRoot%\%TgtDir%\opencv_contrib
if "%GitBranch%"=="" (
  git clone https://github.com/opencv/opencv_contrib.git .
) else (
  git clone -b %GitBranch% https://github.com/opencv/opencv_contrib.git .
)
if not "%GitTag%"=="" (
  git checkout -b %GitTag% refs/tags/%GitTag%
)
pause
popd

rem mkdir ..\opencv\dev
rem xcopy /E ..\eigen\*.* ..\opencv\dev\eigen\
