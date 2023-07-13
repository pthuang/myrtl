onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider tb_spi
add wave -noupdate /tb_spi/*

add wave -noupdate -divider spi_master
add wave -noupdate /tb_spi/spi_master/*

add wave -noupdate -divider spi_slave
add wave -noupdate /tb_spi/spi_slave/*


configure wave -signalnamewidth 1
