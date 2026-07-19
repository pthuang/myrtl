@echo off
REM Run simulation with GUI waveform

set bin_path=D:\modeltech64_2020.4\win64
call %bin_path%/vsim -do "do {tb_top_simulate.do}" -l simulate.log

if "%errorlevel%"=="1" goto END
if "%errorlevel%"=="0" goto SUCCESS
:END
echo SIMULATION FAILED (check simulate.log)
exit 1
:SUCCESS
echo SIMULATION PASSED
exit 0
