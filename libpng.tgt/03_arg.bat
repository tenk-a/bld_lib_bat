set A=%1
if /I "%A:~0,9%"=="ZlibIncDir:" set ZlibIncDir=%A:~10%
if /I "%A:~0,9%"=="ZlibLibDir:" set ZlibLibDir=%A:~10%
if /I "%A:~0,9%"=="ZlibFile:"   set ZlibFile=%A:~9%
