############################################
# Generate Bitstream  
############################################
proc runToGenerateBit {} {
    launch_runs impl_1 -to_step write_bitstream -jobs 12 
    wait_on_run impl_1
}

# implementation check 
set implStatus [get_property status [get_runs impl_1]]
puts "__________| Implementation Status is:$implStatus |__________"

if {[string equal $implStatus "write_bitstream Complete!"]} {
    if {[get_property NEEDS_REFRESH [get_runs impl_1]]} {
        runToGenerateBit
    } else { 
        puts "__________| write_bitstream Complete and Don't need refresh! |__________" 
    }
} else {
    runToGenerateBit 
}
