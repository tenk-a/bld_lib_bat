rem generate to misc_inc, misc_lib
if exist bld_zlib.bat           call bld_zlib.bat	%1
if exist bld_bzip2.bat          call bld_bzip2.bat	%1
if exist bld_libpng.bat         call bld_libpng.bat	%1
rem if exist bld_jpeg.bat           call bld_jpeg.bat	%1
rem if exist bld_libjpeg-turbo.bat  call bld_libjpeg-turbo.bat	%1
if exist bld_mozjpeg.bat        call bld_mozjpeg.bat	%1
if exist bld_libtiff.bat        call bld_libtiff.bat	%1
if exist bld_libharu.bat        call bld_libharu.bat	%1
if exist bld_glfw.bat           call bld_glfw.bat	%1
if exist bld_libogg.bat         call bld_libogg.bat	%1
if exist bld_libvorbis.bat      call bld_libvorbis.bat	%1
if exist bld_pixman.bat         call bld_pixman.bat	%1
if exist bld_cairo.bat          call bld_cairo.bat	%1
if exist bld_openssl.bat        call bld_openssl.bat	%1
