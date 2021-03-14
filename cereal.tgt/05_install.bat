rem flatbuffers : header only library
set SrcIncDir=include\cereal
set DstIncDir=%CcInstallIncDir%\cereal
if exist     "%DstIncDir%" del /q "%DstIncDir%\*.*"
if not exist "%DstIncDir%" mkdir "%DstIncDir%"

xcopy %SrcIncDir% %DstIncDir% /R /Y /I /K /E
