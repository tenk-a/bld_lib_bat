@echo off
rem This batch-file license: boost software license version 1.0
setlocal
call libs_config.bat

set TgtName=cairo
set TgtDir=
set SrcIncSubDir=src
set SrcLibSubDir=
set DstIncSubDir=cairo
set DstLibSubDir=
set hdr1=cairo*.h
set hdr2=
set hdr3=
set hdr4=
set hdr5=
set hdr6=
set hdr7=
set hdr8=
set hdr9=
set Arg=
set NeedTinyReplStr=1

pushd %~dp0
call sub\subr_bld_type1.bat %*
popd

endlocal
