vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

# DUT — instrumented for coverage
vlog -work xil_defaultlib -incr -mfcu +cover \
"../../../src/imports/arbitor/arbitor.v"

# TB — NOT instrumented
vlog -work xil_defaultlib -incr -mfcu \
"../../tb_arbitor/tb_arbitor.v"

# glbl — NOT instrumented
vlog -work xil_defaultlib \
"glbl.v"
