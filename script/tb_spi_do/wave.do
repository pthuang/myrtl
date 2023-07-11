onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider tb_spi_user
add wave -noupdate /tb_spi_user/*

add wave -noupdate -divider spi_master
add wave -noupdate /tb_spi_user/spi_master/*

add wave -noupdate -divider spi_slave
add wave -noupdate /tb_spi_user/spi_slave/*


configure wave -signalnamewidth 1
