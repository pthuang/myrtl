# process define 
proc findFiles {path result args } {
    if {![file exists $path] || ![file isdirectory $path]} {
        return -code error "__________| File not exists or not a directory. |__________"
    }
    # set files [glob -nocomplain -directory $path/ -tails *]
    set files [glob -nocomplain -directory $path/ *]
    foreach i_file $files {
        if {[file isfile $i_file]} {
            set fileExtName [file extension $i_file]    
            foreach i_args $args {
                if {$fileExtName == $i_args} {
                    puts "__________| Object File Name is:$i_file |__________"
                    # puts $i_file
                    # puts [string length $path]
                    # puts [string range $i_file [string length $path]+1 end]
                    # puts [string range $i_file [string length $path]+1 end-[string length $i_args]]
                    puts $result $i_file  
                }
            }
        } 
    }
    
    foreach i_file $files {
        if {[file isdirectory $i_file]} { 
            # recursion
            findFiles $i_file $result [lindex $args 0 end]
        } 
    }
}



