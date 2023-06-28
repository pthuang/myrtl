############################################
# path define 
############################################
set batDir [pwd]
set tclDir $batDir/tcl/


cd .. 
pwd 
set fpgaXprDir [pwd]
set srcDir    $fpgaXprDir/src
set hdlDir    $srcDir/imports 
set constrDir $srcDir/constrs 
set ipDir     $srcDir/ip 
set bdDir     $srcDir/bd 
set simDir    $fpgaXprDir/sim 
cd $batDir

############################################
# read project name from "xprname.txt"
############################################
set fid [open $tclDir/xprname.txt r]
set xprName [read $fid]
close $fid
set xprDir $batDir/$xprName/

############################################
# save project use tcl files
############################################
cd $xprDir
# open project 
open_project $xprName.xpr 
cd ..

# save project to .tcl
# write_project_tcl -use_bd_files -force $xprName.tcl
