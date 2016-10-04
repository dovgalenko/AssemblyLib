@echo off

rem
rem   CVS $Revision: 1.1 $$Date: 2004/07/26 10:16:01 $
rem
rem

set _MASM_PATH_=\masm32\bin\
set _ML_PARAMS_=/I\masm32\include /c /coff /nologo
set _LINK_PARAMS_=/SUBSYSTEM:WINDOWS /RELEASE /LIBPATH:\masm32\lib /nologo
cls

echo Компиляция файлов...
for %%x in (*.asm) do %_MASM_PATH_%ml %_ML_PARAMS_% %%x
echo.

echo Сборка EXE...
%_MASM_PATH_%link %_LINK_PARAMS_% Test.Obj

echo Чистка за собой...
del *.obj

echo Готово.
