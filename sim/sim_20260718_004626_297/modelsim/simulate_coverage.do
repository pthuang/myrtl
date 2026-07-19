onbreak {quit -f}
onerror {quit -f}

vsim -coverage -voptargs="+acc" -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -L xpm -lib xil_defaultlib xil_defaultlib.tb_arbitor xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {tb_arbitor.udo}

run 5ms

# Export coverage after bounded-time simulation completes
coverage save coverage.ucdb
coverage report -output coverage_report.txt -srcfile=* -detail -dump -annotate -option -codeAll
puts "COVERAGE_EXPORT_DONE"

quit -force
