############################################
# export platform file(.hdf or .xsa) 
############################################
set topName [get_property top [current_fileset]] 
puts "__________| Vivido Project Top Hierarchy Module Name is: $topName |__________"

write_hw_platform -fixed -force -file $vitisDir/$topName.xsa
# write_hw_platform -fixed -force -include_bit -file $vitisDir/$topName.xsa
