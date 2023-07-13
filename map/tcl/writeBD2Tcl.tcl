############################################
# Write Vivado BlockDesign to .tcl file  
############################################
update_compile_order -fileset sources_1

set fid [open $tclDir/listBd.txt r]
set bdName [read $fid]

foreach line $bdName {
	set bdname [string range [file dirname $line] [string length $bdDir]+1 end]
	puts "__________| Object ip File is:$line |__________"
	puts "__________| Object bd Name is:$bdname |__________"
	open_bd_design $line
	write_bd_tcl -force $bdDir/$bdname.tcl
	close_bd_design [get_bd_designs $bdname]
}
close $fid 
