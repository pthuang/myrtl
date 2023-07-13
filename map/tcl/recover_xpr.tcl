############################################
# path define 
############################################
set batDir [pwd]
set tclDir $batDir/tcl/

# Environment configuration
source $tclDir/configEnvironment.tcl 

############################################
# read bd name from "listBd.txt"
############################################
set fid [open $tclDir/listBd.txt r]
set bdName [read $fid]
puts $bdName
close $fid

############################################
# recover bd file
############################################
cd $srcDir
foreach i_bd $bdName { 
    # puts [file dirname $i_bd]
    # puts [string range $i_bd [string length [file dirname $i_bd]]+1 end-3]
    set bdname [string range $i_bd [string length [file dirname $i_bd]]+1 end-3]
    puts ./bd/$bdname.tcl

    cd ./bd/
    if {[file isdirectory $bdname]} { 
        cd ..  
        puts "BD $bdname is exist!"
    } else {
        cd ..
        source ./bd/$bdname.tcl
        puts "BD $bdname is recovered!"
        regenerate_bd_layout
        # close_bd_design 
        close_bd_design [get_bd_designs $bdname] 
        # new a variable
        set BDRECOVERED 1
    }
}

puts [info exist BDRECOVERED]
if {[info exist BDRECOVERED]} { 
    # close_project unused 
    close_project 
    # delete unused file 
    file delete -force NA
    file delete -force myproj
    file delete -force .Xil
    # delete BDRECOVERED
    unset BDRECOVERED 
}

############################################
# recover xpr file
############################################
cd $batDir 
puts $xprName.tcl

if {[file isdirectory $xprName]} { 
    puts "Project $xprName is exist!"
    # open project 
    cd $xprDir
    source $tclDir/openXpr.tcl
    cd .. 
} else { 
    source $xprName.tcl
    puts "Project $xprName is recovered!" 
}

update_compile_order -fileset sources_1 

set_param general.maxthreads 16 
get_param general.maxthreads

start_gui
