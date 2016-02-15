set LIBS_VC=..\..\..
set MISC_INC=%LIBS_VC%\misc_inc
set MISC_LIB=%LIBS_VC%\misc_lib\x86_static
cl -MT -EHsc -I%LIBS_VC%\boost_1_60_0 -I%MISC_INC% rgb8_jpg2pngtiff.cpp -link /LIBPATH:%MISC_LIB%
