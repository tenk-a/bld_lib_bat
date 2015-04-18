setlocal
rem This batch-file license: boost software license version 1.0
echo /// %1 wrapper
echo #pragma once
echo #include "../%2/%1"
echo #ifdef _MSC_VER
echo #pragma comment(lib, "%3")
echo #endif
endlocal
