############################################
# Write Vivado Project to .tcl file  
############################################
update_compile_order -fileset sources_1
puts $xprName
# save project to .tcl
write_project_tcl -use_bd_files -force $xprName.tcl 
