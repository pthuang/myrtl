# compile verilog file
vlog -93 -work work $SimHome/tb_m_spi/tb_m_spi.v $DoHome/glbl.v \
					$SrcHome/imports/spi/m_spi.v \
					$SrcHome/imports/spi/s_spi.v \

# compile VHDL file
# vcom -93 -work xbip_utils_v3_0_10 $SrcHome/xxx/xxx.vhd

# start simulation
vsim -t ns -voptargs="+acc" -L work work.tb_m_spi work.glbl 


set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do $WaveHome/wave.do  

view wave
view structure
view signals

log -r */

# set simulation time(us)
set sim_time 3000

run $sim_time us 
# run -all
 