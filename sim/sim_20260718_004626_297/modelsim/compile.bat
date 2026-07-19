@echo off
REM Compile DUT + testbench (console mode)

set bin_path=D:\modeltech64_2020.4\win64
call %bin_path%/vsim -c -do "do {tb_top_compile.do}" -l compile.log

if "%errorlevel%"=="1" goto END
if "%errorlevel%"=="0" goto SUCCESS
:END
echo COMPILATION FAILED (check compile.log)
exit 1
:SUCCESS
echo COMPILATION PASSED
exit 0
