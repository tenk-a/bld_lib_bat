if not exist tiny_replstr.exe (
  cl /EHsc /Fetiny_replstr.exe src\tiny_replstr.cpp
  del *.obj
)
