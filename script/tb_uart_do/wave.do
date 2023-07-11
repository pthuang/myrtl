onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider tb_uart
add wave -noupdate /tb_uart/*

add wave -noupdate -divider uart_tx
add wave -noupdate /tb_uart/uart_tx/*

add wave -noupdate -divider uart_rx
add wave -noupdate /tb_uart/uart_rx/*


configure wave -signalnamewidth 1
