quit -sim  
.main clear

puts [pwd]
# shift to upper level direction
cd .. 

set BaseHome [pwd]
set DoHome  $BaseHome/script/ 
set SrcHome $BaseHome/src/ 
set SimHome $BaseHome/sim/ 
set WaveHome $DoHome/tb_arbitor_do

cd $DoHome 

if {[file exists work]} {
	puts "work path is exists!"
} else {
	vlib ./work
}

vmap work ./work/

do $WaveHome/compile.do
 
