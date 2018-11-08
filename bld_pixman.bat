@echo off
rem This batch-file license: boost software license version 1.0
setlocal
call libs_config.bat

set TgtName=pixman
set TgtDir=
set SrcIncSubDir=pixman
set SrcLibSubDir=
set DstIncSubDir=
set DstLibSubDir=
set hdr1=pixman.h
set hdr2=pixman-version.h
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
