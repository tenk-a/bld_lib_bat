set A=%1
if /I "%A:~0,11%"=="ZlibIncDir:" set ZlibIncDir=%A:~11%
if /I "%A:~0,11%"=="ZlibLibDir:" set ZlibLibDir=%A:~11%
if /I "%A:~0,10%"=="PngIncDir:"  set PngIncDir=%A:~10%
if /I "%A:~0,10%"=="PngLibDir:"  set PngLibDir=%A:~10%
