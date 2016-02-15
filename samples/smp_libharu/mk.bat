set LIBS_VC=..\..\..
set MISC_INC=%LIBS_VC%\misc_inc
set MISC_LIB=%LIBS_VC%\misc_lib\x86_static
cl -MT -EHsc -I%MISC_INC% smp_jpg2pdf.cpp -link /LIBPATH:%MISC_LIB%
