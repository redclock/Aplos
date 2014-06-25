@echo off
if '%1'=='sub' goto g1
echo compile result>compall.txt
echo -------------------------->comperr.txt
for %%f in (*.apl) do call compileall sub %%f
echo OK!
echo.
echo And there are errors:
type comperr.txt
pause
goto end
:g1
echo %2
..\Bin\aplos /n %2>>compall.txt
if errorlevel 1 echo %2>>comperr.txt  
:end
