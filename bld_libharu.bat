rem @echo off
rem This batch-file license: boost software license version 1.0
setlocal
call libs_config.bat

set TgtName=libharu
set TgtDir=
set SrcIncSubDir=
set SrcLibSubDir=
set DstIncSubDir=libharu
set DstLibSubDir=
set hdr1=include\*.h
set hdr2=win32\include\hpdf_config.h
set hdr3=
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
