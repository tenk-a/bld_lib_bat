@echo off
rem This batch-file license: boost software license version 1.0
setlocal
call libs_config.bat

set TgtName=mozjpeg
set TgtDir=
set SrcIncSubDir=
set SrcLibSubDir=
set DstIncSubDir=
set DstLibSubDir=
set hdr1=jpeglib.h
set hdr2=jconfig.h
set hdr3=jmorecfg.h
set hdr4=jpegint.h
set hdr5=jerror.h
set hdr6=turbojpeg.h
set hdr7=
set hdr8=
set hdr9=
set Arg=

pushd %~dp0
call sub\subr_bld_type1.bat %*
popd

endlocal
