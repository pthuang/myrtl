# compile systemverilog file
vlog -93 -sv -work work $SimHome/tb_pulse_test/tb_pulse_test.sv \
						$SrcHome/imports/pulse/pulse_generate.sv \
						$SrcHome/imports/pulse/pulse_coarctation.sv \
						$SrcHome/imports/pulse/pulse_delay.sv \
						$SrcHome/imports/pulse/pulse_hold.sv \
					    $SrcHome/imports/pulse/pulse_extend.sv	

# compile verilog file
vlog -93 -work work $DoHome/glbl.v \

# compile VHDL file
# vcom -93 -work work $SrcHome/ip/ddr_mult/synth/ddr_mult.vhd

# start simulation
vsim -t ns -voptargs="+acc" -L work -L blk_mem_gen_v8_4_4 -L work -L dist_mem_gen_v8_0_13 \
							-L unisims_ver -L unimacro_ver -L secureip -L xpm -lib work \
							work.tb_pulse_test work.glbl 

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do $WaveHome/wave.do  

view wave
view structure
view signals

log -r */

# set simulation time(us)
set sim_time 20

run $sim_time us 
# run -all
 