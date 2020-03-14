mkdir %CcLibsRoot%\opencv
git clone -b %GitBranch% https://github.com/opencv/opencv.git %CcLibsRoot%\%TgtDir%\source
git clone -b %GitBranch% https://github.com/opencv/opencv_contrib.git %CcLibsRoot%\%TgtDir%\opencv_contrib
rem mkdir ..\opencv\dev
rem xcopy /E ..\eigen\*.* ..\opencv\dev\eigen\
