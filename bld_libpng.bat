@echo off
rem This batch-file license: boost software license version 1.0
setlocal

set TgtName=libpng
set TgtDir=
set SrcIncSubDir=
set SrcLibSubDir=
set DstIncSubDir=
set DstLibSubDir=
set hdr1=png.h
set hdr2=pngconf.h
set hdr3=pnglibconf.h
set hdr4=
set hdr5=
set hdr6=
set hdr7=
set hdr8=
set hdr9=
set Arg=

pushd %~dp0
call sub\subr_bld_type1.bat %*
popd

endlocal
