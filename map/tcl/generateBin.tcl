############################################
# Generate & Backup Bitstream  
############################################

# modify bit file name  
cd $bitBackupDir 
file delete FPGA.bin
if {[file exist su_top_v2.bit]} {
	file rename -force ./su_top_v2.bit ./FPGA.bit
	file rename -force ./su_top_v2.ltx ./FPGA.ltx
}

# # bootgen 
# bootgen -w on -image output.bif -arch zynq -process_bitstream bin

# # modify bit file name  
# file rename -force ./FPGA.bit.bin ./FPGA.bin
# cd ..
 