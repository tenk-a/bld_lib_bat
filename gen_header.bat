setlocal
rem This batch-file license: boost software license version 1.0

if not exist %4 mkdir %4
call :Print %1 %2 %3 >%4\%1

endlocal
goto :EOF

:Print
echo /// %1 wrapper
echo #pragma once
echo #include "../../%2/%1"
echo #ifdef _MSC_VER
echo #pragma comment(lib, "%3")
echo #endif
exit /b
