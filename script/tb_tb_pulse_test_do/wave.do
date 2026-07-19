onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider tb_pulse_test
add wave -noupdate /tb_pulse_test/*

add wave -noupdate -divider pulse_generate
add wave -noupdate /tb_pulse_test/pulse_generate/*

add wave -noupdate -divider pulse_coarctation
add wave -noupdate /tb_pulse_test/pulse_coarctation/*

add wave -noupdate -divider pulse_hold
add wave -noupdate /tb_pulse_test/pulse_hold/*

add wave -noupdate -divider pulse_delay
add wave -noupdate /tb_pulse_test/pulse_delay/*

add wave -noupdate -divider pulse_extend
add wave -noupdate /tb_pulse_test/pulse_extend/*

# add wave -noupdate -divider pulse_extend_d
# add wave -noupdate /tb_pulse_test/pulse_extend/pulse_delay/*

# add wave -noupdate -divider pulse_extend_h
# add wave -noupdate /tb_pulse_test/pulse_extend/pulse_hold/*
configure wave -signalnamewidth 1