###############################################################
# process decalration 
###############################################################
source findFiles.tcl


###############################################################
# scan source files 
###############################################################
cd $fpgaXprDir
if {[file exist src]} {
	cd $tclDir
	# scan 
	set srcFileName "./listSrc.txt"
	set srcPath $hdlDir
	set status [catch {set fid [open $srcFileName w+]} msg]
	if {$status} { 
		puts $msg
	} 
	findFiles $srcPath $fid ".v" ".vh" ".vhd" ".sv"
	close $fid
} else {
	puts "Directory is not exist and will create it!"
	file mkdir src 
	cd $tclDir
}


###############################################################
# scan simulation files 
###############################################################
cd $fpgaXprDir
if {[file exist sim]} {
	cd $tclDir
	# scan 
	set simFileName "./listSim.txt"
	set simPath $simDir
	set status [catch {set fid [open $simFileName w+]} msg]
	if {$status} { 
		puts $msg
	}
	findFiles $simPath $fid ".v" ".vh" ".vhd" ".sv"
	close $fid
} else {
	puts "Directory is not exist and will create it!"
	file mkdir sim 
	cd $tclDir
}


###############################################################
# scan block design files 
###############################################################
cd $srcDir
if {[file exist bd]} {
	cd $tclDir
	# scan 
	set bdFileName "./listBd.txt"
	set bdPath $bdDir
	set status [catch {set fid [open $bdFileName w+]} msg]
	if {$status} { 
		puts $msg
	}
	findFiles $bdPath $fid ".bd"
	close $fid
} else {
	puts "Directory is not exist and will create it!"
	file mkdir bd 
	cd $tclDir
}


###############################################################
# scan ip files 
###############################################################
cd $srcDir
if {[file exist ip]} {
	cd $tclDir
	# scan 
	set ipFileName "./listIp.txt"
	set ipPath $ipDir
	set status [catch {set fid [open $ipFileName w+]} msg]
	if {$status} { 
		puts $msg
	} 
	findFiles $ipPath $fid ".xci"
	close $fid
} else {
	puts "Directory is not exist and will create it!"
	file mkdir ip 
	cd $tclDir
}


###############################################################
# scan constrains files 
###############################################################
cd $srcDir
if {[file exist constrs]} {
	cd $tclDir
	# scan 
	set constrFileName "./listConstr.txt"
	set constrPath $constrDir
	set status [catch {set fid [open $constrFileName w+]} msg]
	if {$status} { 
		puts $msg
	}
	findFiles $constrPath $fid ".xdc" ".ucf" 
	close $fid
} else {
	puts "Directory is not exist and will create it!"
	file mkdir constrs 
	cd $tclDir
}


