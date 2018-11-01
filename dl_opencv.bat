mkdir ..\opencv
git clone -b 3.4 https://github.com/opencv/opencv.git ..\opencv\source
git clone -b 3.4 https://github.com/opencv/opencv_contrib.git ..\opencv\opencv_contrib
rem mkdir ..\opencv\dev
rem xcopy /E ..\eigen\*.* ..\opencv\dev\eigen\
