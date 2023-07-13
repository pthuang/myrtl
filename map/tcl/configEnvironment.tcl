############################################
# config Environment
############################################
set vitisDir $batDir/vitis
set bitBackupDir $batDir/bit

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

# read project name from "xprname.txt"
set fid [open $tclDir/xprname.txt r]
set xprName [read $fid]
close $fid
set xprDir $batDir/$xprName

set bitDir $xprDir/$xprName.runs/impl_1