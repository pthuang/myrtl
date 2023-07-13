############################################
# open Xilinx Vivado Project 
############################################
open_project $xprName.xpr
set_param general.maxthreads 16 
update_compile_order -fileset sources_1

