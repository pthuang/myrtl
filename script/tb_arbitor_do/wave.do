onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider tb_arbitor
add wave -noupdate /tb_arbitor/log_clk
add wave -noupdate /tb_arbitor/log_rst
add wave -noupdate /tb_arbitor/link_initialized
add wave -noupdate /tb_arbitor/iotx_tvalid
add wave -noupdate /tb_arbitor/wr_evt_1
add wave -noupdate /tb_arbitor/wr_evt_2
add wave -noupdate /tb_arbitor/wr_evt_3
add wave -noupdate /tb_arbitor/wr_evt_4
add wave -noupdate /tb_arbitor/wr_evt_5
add wave -noupdate /tb_arbitor/wr_evt_6
add wave -noupdate /tb_arbitor/wr_evt_7
add wave -noupdate /tb_arbitor/wr_evt_8
add wave -noupdate /tb_arbitor/wr_evt_9
add wave -noupdate /tb_arbitor/evt1_out
add wave -noupdate /tb_arbitor/evt2_out
add wave -noupdate /tb_arbitor/evt3_out
add wave -noupdate /tb_arbitor/evt4_out
add wave -noupdate /tb_arbitor/evt5_out
add wave -noupdate /tb_arbitor/evt6_out
add wave -noupdate /tb_arbitor/evt7_out
add wave -noupdate /tb_arbitor/evt8_out
add wave -noupdate /tb_arbitor/evt9_out
add wave -noupdate -divider arbitor
add wave -noupdate /tb_arbitor/arbitor/clk
add wave -noupdate /tb_arbitor/arbitor/rst
add wave -noupdate /tb_arbitor/arbitor/link_initialized
add wave -noupdate /tb_arbitor/arbitor/iotx_tvalid
add wave -noupdate /tb_arbitor/arbitor/event_in_0
add wave -noupdate /tb_arbitor/arbitor/event_in_1
add wave -noupdate /tb_arbitor/arbitor/event_in_2
add wave -noupdate /tb_arbitor/arbitor/event_in_3
add wave -noupdate /tb_arbitor/arbitor/event_in_4
add wave -noupdate /tb_arbitor/arbitor/event_in_5
add wave -noupdate /tb_arbitor/arbitor/event_in_6
add wave -noupdate /tb_arbitor/arbitor/event_in_7
add wave -noupdate /tb_arbitor/arbitor/event_in_8
add wave -noupdate /tb_arbitor/arbitor/event_out_0
add wave -noupdate /tb_arbitor/arbitor/event_out_1
add wave -noupdate /tb_arbitor/arbitor/event_out_2
add wave -noupdate /tb_arbitor/arbitor/event_out_3
add wave -noupdate /tb_arbitor/arbitor/event_out_4
add wave -noupdate /tb_arbitor/arbitor/event_out_5
add wave -noupdate /tb_arbitor/arbitor/event_out_6
add wave -noupdate /tb_arbitor/arbitor/event_out_7
add wave -noupdate /tb_arbitor/arbitor/event_out_8
add wave -noupdate /tb_arbitor/arbitor/evt_flag0
add wave -noupdate /tb_arbitor/arbitor/evt_flag1
add wave -noupdate /tb_arbitor/arbitor/evt_flag2
add wave -noupdate /tb_arbitor/arbitor/evt_flag3
add wave -noupdate /tb_arbitor/arbitor/evt_flag4
add wave -noupdate /tb_arbitor/arbitor/evt_flag5
add wave -noupdate /tb_arbitor/arbitor/evt_flag6
add wave -noupdate /tb_arbitor/arbitor/evt_flag7
add wave -noupdate /tb_arbitor/arbitor/no_evt_out
add wave -noupdate /tb_arbitor/arbitor/no_evt
add wave -noupdate /tb_arbitor/arbitor/cnt_1s
add wave -noupdate /tb_arbitor/arbitor/ready_dly
add wave -noupdate -expand /tb_arbitor/arbitor/fifo
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2091 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {1988 ns} {2167 ns}
