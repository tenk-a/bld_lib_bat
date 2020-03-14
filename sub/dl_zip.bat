if not exist %CD%\tmp mkdir %CD%\tmp
if not exist %CD%\tmp\%2.zip (
  bitsadmin /TRANSFER "download" /PRIORITY normal %1 %CD%\tmp\%2.zip
)
powershell Expand-Archive -Path tmp\%2.zip -DestinationPath %CcLibsRoot%
if "%3"==""   goto SKIP1
if "%2"=="%3" goto SKIP1
move ..\%2 ..\%3
:SKIP1
