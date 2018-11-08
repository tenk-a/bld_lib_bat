@echo off
rem This batch-file license: boost software license version 1.0
setlocal

set TgtName=fks
set TgtDir=
set SrcIncSubDir=
set SrcLibSubDir=
set DstIncSubDir=
set DstLibSubDir=
set hdr1=
set hdr2=
set hdr3=
set hdr4=
set hdr5=
set hdr6=
set hdr7=
set hdr8=
set hdr9=
set Arg=
set NoCopy=1

pushd %~dp0
call sub\subr_bld_type1.bat %*
popd

endlocal
