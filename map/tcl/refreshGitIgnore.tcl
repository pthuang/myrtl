############################################
# update .gitignore depend on "listIp.txt"
############################################
set status [catch {set fid0 [open ".gitignore" w+]} msg]
if {$status} { 
	puts $msg
}


puts $fid0 "#######################################################"
puts $fid0 "#                                                      "
puts $fid0 "#       git management rule Settings                   "
puts $fid0 "#       ! means need add to git                        "
puts $fid0 "#       otherwise means need to ignore                 "
puts $fid0 "#                                                      "
puts $fid0 "# Can test by \"git status -u\" check if rules valid   "
puts $fid0 "#                                                      "
puts $fid0 "#######################################################"
puts $fid0 "# ignore all files in root directory"
puts $fid0 "/*"

puts $fid0 "# except \".gitignore\" file "
puts $fid0 "!.gitignore"
puts $fid0 "# except \".readme.md\" file "
puts $fid0 "!readme.md"

puts $fid0 "# except map directory"
puts $fid0 "!/map/"
puts $fid0 "# ignore $xprName directory in map directory"
puts $fid0 "/map/$xprName/*" 
puts $fid0 "/map/*.bat" 
puts $fid0 "/map/*.jou" 
puts $fid0 "/map/*.log" 
puts $fid0 "/map/*.str" 

puts $fid0 "!/map/vitis/" 
puts $fid0 "/map/vitis/*" 
puts $fid0 "!/map/vitis/*.xsa" 
puts $fid0 "!/map/vitis/*.bit" 
puts $fid0 "!/map/vitis/$xprName/" 
puts $fid0 "/map/vitis/$xprName/*" 
puts $fid0 "!/map/vitis/$xprName/src/" 
puts $fid0 "/map/vitis/$xprName/src/*" 
puts $fid0 "!/map/vitis/$xprName/src/*.c" 
puts $fid0 "!/map/vitis/$xprName/src/*.h" 
puts $fid0 "!/map/vitis/$xprName/src/*.ld" 

puts $fid0 "# script directory"
puts $fid0 "!/script/"
puts $fid0 "/script/*"

set simfid [open $tclDir/listSim.txt r]
set simfile [read $simfid]
foreach line $simfile { 
	set tbname [string range [file dirname $line] [string length $simDir]+1 end]
	puts "__________| Object ip File is:$line |__________"
	puts "__________| Object ip Name is:$tbname |__________" 
	set doname [append tbname "_do"]
	puts $fid0 "!/script/$doname/" 
	# puts $fid0 "/src/ip/$doname/*"
	# puts $fid0 "!/src/ip/$doname/*.do"
}
close $simfid
puts $fid0 "!/script/*.bat"
puts $fid0 "!/script/*.do"

puts $fid0 "# sim directory"
puts $fid0 "!/sim/"

puts $fid0 "# src directory"
puts $fid0 "!/src/"
puts $fid0 "/src/bd/*"

puts $fid0 "# bd directory"
puts $fid0 "!/src/bd/*.tcl"
# set bdfid [open $tclDir/listBd.txt r]
# set bdfile [read $bdfid]
# foreach line $bdfile { 
# 	puts [string range [file dirname $line] [string length $ipDir]+1 end]
# 	puts $fid0 "!/src/bd/[string range [file dirname $line] [string length $ipDir]+1 end]/"
# 	puts $fid0 "/src/bd/[string range [file dirname $line] [string length $ipDir]+1 end]/*"
# 	puts $fid0 "!src/bd/[string range [file dirname $line] [string length $ipDir]+1 end]/*.bd"
# 	puts $fid0 "!src/bd/[string range [file dirname $line] [string length $ipDir]+1 end]/*.bxml"
# 	puts $fid0 "!src/bd/[string range [file dirname $line] [string length $ipDir]+1 end]/*.v"
# }
# close $bdfid

puts $fid0 "# coe directory"
puts $fid0 "!/src/coe/*"

puts $fid0 "# constrs directory"
puts $fid0 "!/src/constrs/*"

puts $fid0 "# elf directory"
puts $fid0 "!/src/elf/*"

puts $fid0 "# src code directory"
puts $fid0 "!/src/imports/*"

puts $fid0 "# ip directory"
set ipfid [open $tclDir/listIp.txt r]
set ipfile [read $ipfid]
foreach line $ipfile { 
	set ipname [string range [file dirname $line] [string length $ipDir]+1 end]
	puts "__________| Object ip File is:$line |__________"
	# puts $line
	# puts [file dirname $line]
	# puts [file rootname $line]
	# puts [file tail $line]
	# puts [file extension $line]
	# puts [string length $ipDir]
	# puts [string range $line [string length $ipDir]+1 end]
	puts "__________| Object ip Name is:$ipname |__________"
	# puts $ipname
	puts $fid0 "!/src/ip/$ipname/"
	puts $fid0 "/src/ip/$ipname/*"
	puts $fid0 "!src/ip/$ipname/*.xci"
	puts $fid0 "!src/ip/$ipname/*.prj"
	# puts $fid0 "!src/ip/$ipname/*.xml"
	# puts $fid0 "!src/ip/$ipname/*.v"
	# puts $fid0 "!src/ip/$ipname/*.vhd"
	# puts $fid0 "!src/ip/$ipname/*.xdc"
}
close $ipfid

# puts $fid0 "# tcl directory"
# puts $fid0 "!/src/tcl/*"

puts $fid0 "# ip_repo directory"
puts $fid0 "!/src/ip_repo/*"

close $fid0