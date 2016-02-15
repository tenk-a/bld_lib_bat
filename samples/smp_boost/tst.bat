set dstDir=..\tst_output
if not exist %dstDir% mkdir %dstDir%
rgb8_jpg2pngtiff ..\data\img\01.jpg %dstDir%\boost_01.png %dstDir%\boost_01.tif
rgb8_jpg2pngtiff ..\data\img\02.jpg %dstDir%\boost_02.png %dstDir%\boost_02.tif
rgb8_jpg2pngtiff ..\data\img\03.jpg %dstDir%\boost_03.png %dstDir%\boost_03.tif
