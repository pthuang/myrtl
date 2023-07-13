############################################
# Xilinx Vivado Project Git Environment 
# Maintenance Flow Contrl. 
############################################
set batDir [pwd]
set tclDir $batDir/tcl

# Environment configuration
source $tclDir/configEnvironment.tcl

# refresh git rules(.gitignore)
source $tclDir/updateGitRules.tcl

# open project 
cd $xprDir
source $tclDir/openXpr.tcl
cd ..

# save blockdesign to .tcl file 
source $tclDir/writeBD2Tcl.tcl

# save project to .tcl file 
source $tclDir/writeXpr2Tcl.tcl

# run synththesis  
# This line of code is used when all ips use OOC synthesis
# synth_ip [get_ips]
source $tclDir/runSynthesis.tcl

# export platform file(.hdf or .xsa) 
# source $tclDir/exportPlatform.tcl

# generate and backup bit file 
# source $tclDir/runGenerateBit.tcl

# backup bit file 
# source $tclDir/backupBit.tcl

# open Vivado GUI 
start_gui
