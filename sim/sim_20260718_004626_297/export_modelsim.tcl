if {$argc != 1} {
    error "usage: export_modelsim.tcl <absolute-run-directory>"
}
set run_dir [file normalize [lindex $argv 0]]
file mkdir $run_dir
export_simulation \
  -lib_map_path "D:/modeltech64_2020.4/vivado2022_1_lib" \
  -directory $run_dir \
  -simulator modelsim \
  -use_ip_compiled_libs
puts "EXPORT_DONE run_dir=$run_dir"
