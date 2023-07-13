############################################
# refresh git rules(.gitignore)
############################################

# refresh filelist 
cd $tclDir
source $tclDir/scanFile.tcl 
cd .. 

############################################
# update .gitignore depend on "listIp.txt"
############################################
cd $fpgaXprDir
source $tclDir/refreshGitIgnore.tcl
cd $batDir
