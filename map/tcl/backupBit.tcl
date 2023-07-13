############################################
# Generate & Backup Bitstream  
############################################
proc backupFiles {sourcePath DestPath args} {
    set files [glob -nocomplain -directory $sourcePath/ *]
    foreach i_file $files {
        if {[file isfile $i_file]} {
            set fileExtName [file extension $i_file] 
            foreach i_args $args {
                if {$fileExtName == $i_args} {
                    puts "__________| Object File Name is:$i_file |__________" 
                    file copy -force $i_file $DestPath
                }
            }
        } 
    }
}

# implementation check 
set implStatus [get_property status [get_runs impl_1]]
puts "__________| Implementation Status is:$implStatus |__________" 

if {[string equal $implStatus "write_bitstream Complete!"]} {
    backupFiles $bitDir $bitBackupDir ".bit" ".ltx" 
    backupFiles $bitDir $vitisDir ".bit"
} 
