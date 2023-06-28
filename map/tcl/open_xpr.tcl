############################################
# path define 
############################################
set batDir [pwd]
set tclDir $batDir/tcl/

############################################
# read project name from "xprname.txt"
############################################
set fid [open $tclDir/xprname.txt r]
set xprName [read $fid]
close $fid
set xprDir $batDir/$xprName/

cd $xprDir

# open project 
open_project $xprName.xpr

set_param general.maxthreads 16 

cd ..
