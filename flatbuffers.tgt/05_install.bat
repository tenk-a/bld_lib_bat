rem flatbuffers : header only library
set DstIncDir=%CcInstallIncDir%\flatbuffers
if not exist "%DstIncDir%" mkdir "%DstIncDir%"
if exist     "%DstIncDir%" del /q "%DstIncDir%\*.*"

copy /b include\flatbuffers\*.h %DstIncDir%\
