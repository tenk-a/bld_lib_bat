rem flatbuffers : header only library
set DstIncDir=%CcInstallIncDir%
if not exist "%DstIncDir%" mkdir "%DstIncDir%"

set DstIncDir=%DstIncDir%\flatbuffers
if not exist "%DstIncDir%" mkdir "%DstIncDir%"
if exist     "%DstIncDir%" del /q "%DstIncDir%\*.*"

copy /b flatbuffers\include\flatbuffers\*.h %DstIncDir%\
