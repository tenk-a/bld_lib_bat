set srcDir=..\data\img
set dstDir=..\tst_output
if not exist %dstDir% mkdir %dstDir%
smp_jpg2pdf -o%dstDir%\smp_libharu_result.pdf %srcDir%\01.jpg %srcDir%\02.jpg %srcDir%\03.jpg %srcDir%\04.jpg
