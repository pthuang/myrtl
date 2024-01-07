onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider tb_arbitor
add wave -noupdate /tb_arbitor/*

add wave -noupdate -divider arbitor
add wave -noupdate /tb_arbitor/arbitor/*

configure wave -signalnamewidth 1
