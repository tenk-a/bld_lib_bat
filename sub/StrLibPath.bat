rem @echo off
set _TYPE_=%1
set _ROOT_=%2\
set _VC_=%3
set _AR_=%4
set _RT_=%5
set _CF_=%6

@goto StrLipPath_SKIP1
@echo type=%_TYPE_%
@echo root=%_ROOT_%
@echo vcver=%_VC_%
@echo arch=%_AR_%
@echo rt=%_RT_%
@echo conf=%_CF_%
pause
:StrLipPath_SKIP1

if x%_ROOT_%==x_\ set _ROOT_=

set _RtStr_=
if /I "%_RT_%"=="static" set _RtStr_=%CcStrStatic%
if /I "%_RT_%"=="rtdll"  set _RtStr_=%CcStrRtDll%
if /I "%_RT_%"=="dll"    set _RtStr_=%CcStrDll%

set _S_=\
if x%_CF_%==x (
  set _S_=
  set _RtStr_=%_RT_%
)

set StrLibPath=
if /I "%_TYPE_%"=="D_VA"  set StrLibPath=%_ROOT_%%_VC_%\%_AR_%\%_CF_%%_RtStr_%
if /I "%_TYPE_%"=="D_AV"  set StrLibPath=%_ROOT_%%_AR_%\%_VC_%\%_CF_%%_RtStr_%

if /I "%_TYPE_%"=="D_VAR" set StrLibPath=%_ROOT_%%_VC_%\%_AR_%\%_RT_%%_S_%%_CF_%
if /I "%_TYPE_%"=="D_VRA" set StrLibPath=%_ROOT_%%_VC_%\%_RT_%\%_AR_%%_S_%%_CF_%
if /I "%_TYPE_%"=="D_AVR" set StrLibPath=%_ROOT_%%_AR_%\%_VC_%\%_RT_%%_S_%%_CF_%
if /I "%_TYPE_%"=="D_ARV" set StrLibPath=%_ROOT_%%_AR_%\%_RT_%\%_VC_%%_S_%%_CF_%
if /I "%_TYPE_%"=="D_RVA" set StrLibPath=%_ROOT_%%_RT_%\%_VC_%\%_AR_%%_S_%%_CF_%
if /I "%_TYPE_%"=="D_RAV" set StrLibPath=%_ROOT_%%_RT_%\%_AR_%\%_VC_%%_S_%%_CF_%

if /I "%_TYPE_%"=="J_VA"  set StrLibPath=%_ROOT_%%_VC_%_%_AR_%_%_CF_%%_RtStr_%
if /I "%_TYPE_%"=="J_AV"  set StrLibPath=%_ROOT_%%_AR_%_%_VC_%_%_CF_%%_RtStr_%
if /I "%_TYPE_%"=="J_VAR" set StrLibPath=%_ROOT_%%_VC_%_%_AR_%_%_RT_%%_S_%%_CF_%
if /I "%_TYPE_%"=="J_VRA" set StrLibPath=%_ROOT_%%_VC_%_%_RT_%_%_AR_%%_S_%%_CF_%
if /I "%_TYPE_%"=="J_AVR" set StrLibPath=%_ROOT_%%_AR_%_%_VC_%_%_RT_%%_S_%%_CF_%
if /I "%_TYPE_%"=="J_ARV" set StrLibPath=%_ROOT_%%_AR_%_%_RT_%_%_VC_%%_S_%%_CF_%
if /I "%_TYPE_%"=="J_RVA" set StrLibPath=%_ROOT_%%_RT_%_%_VC_%_%_AR_%%_S_%%_CF_%
if /I "%_TYPE_%"=="J_RAV" set StrLibPath=%_ROOT_%%_RT_%_%_AR_%_%_VC_%%_S_%%_CF_%

rem @echo %StrLibPath%
rem @pause

set _TYPE_=
set _ROOT_=
set _VC_=
set _AR_=
set _RT_=
set _CF_=
set _RtStr_=
set _S_=