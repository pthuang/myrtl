set xprDir [get_property directory [current_project]]
set bitDir [get_property directory [get_runs impl_1]]

cd $xprDir
cd .. 

set batDir [pwd]
set tclDir $batDir/tcl
set bitBackupDir $batDir/bit

# backup bit file 
source $tclDir/backupBit.tcl

cd $bitBackupDir 
# modify bit file name  
file rename -force ./su_top_v2.bit ./FPGA.bit

# generate bin file 
if {[file exist output.bif]} {
	puts "output.bif file is exist" 
} else {
	set fileName "./output.bif"
	set fid [open $fileName w+] 
	puts $fid "the_ROM_image:"
	puts $fid "{"
	puts $fid "    FPGA.bit"
	puts $fid "}"
	close $fid 
	puts "output.bif file is created now!" 
}

# source $tclDir/generateBin.tcl
# source ./generateBin.tcl
# bootgen -w on -image output.bif -arch zynq -process_bitstream bin
# source ./generateBin.tcl

# modify bit file name  
# file rename -force ./FPGA.bit.bin ./FPGA.bin 

# cd $batDir 