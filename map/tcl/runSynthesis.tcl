############################################
# Write Vivado Project to .tcl file  
############################################
# synthesis check 
set synthStatus [get_property status [get_runs synth_1]]
puts "__________| Synthesis Status is:$synthStatus |__________"

if {[string equal $synthStatus "synth_design Complete!"]} {
    if {[get_property NEEDS_REFRESH [get_runs synth_1]]} {
        reset_run synth_1
		launch_runs synth_1
		wait_on_run synth_1
    } else {
    	puts "__________| synth_design Complete and Don't need refresh! |__________" 
    }
} else {
    reset_run synth_1
	launch_runs synth_1
	wait_on_run synth_1
}
