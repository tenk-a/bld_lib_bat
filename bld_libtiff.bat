rem @echo off
rem This batch-file license: boost software license version 1.0
setlocal
call libs_config.bat

set TgtName=libtiff
set TgtDir=
set SrcIncSubDir=libtiff
set SrcLibSubDir=
set DstIncSubDir=
set DstLibSubDir=
set hdr1=tiff.h
set hdr2=tiffconf.h
set hdr3=tiffio.h
set hdr4=tiffio.hxx
set hdr5=tiffvers.h
set hdr6=
set hdr7=
set hdr8=
set hdr9=
set Arg=

pushd %~dp0
call sub\subr_bld_type1.bat %*
popd

endlocal
