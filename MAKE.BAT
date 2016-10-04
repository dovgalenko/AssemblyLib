@echo off

rem
rem   $Id: MAKE.BAT,v 1.10 2004/07/27 07:50:20 ╧ртхы Exp $
rem
rem

set _LIB_NAME_=Lib\ChemistLib.Lib
set _MASM_PATH_=\masm32\bin\
set _MASM_ROOT_=\masm32\
set _ML_PARAMS_=/I\masm32\include /c /coff /nologo
set _LINK_PARAMS_=/out:%_LIB_NAME_% /subsystem:WINDOWS /nologo
set _OPT_ML_PARAMS_=/DCOMPILE_INFO

cls

echo Компиляция файлов...
if exist %1 goto OneFile
for %%x in (*.asm) do %_MASM_PATH_%ml %_ML_PARAMS_% %_OPT_ML_PARAMS_% %%x
goto Done
:OneFile
%_MASM_PATH_%ml %_ML_PARAMS_% %_OPT_ML_PARAMS_% %1 
:Done
echo.

echo Сборка библиотеки...
move *.obj Obj >nul
%_MASM_PATH_%lib Obj\*.obj %_LINK_PARAMS_%

echo Установка библиотеки...
copy "%_LIB_NAME_%" %_MASM_ROOT_%%_LIB_NAME_% > nul
copy ChemistLib.Inc %_MASM_ROOT_%Include\ChemistLib.Inc > nul
type Const.Inc >> %_MASM_ROOT_%Include\ChemistLib.Inc

echo Готово.
