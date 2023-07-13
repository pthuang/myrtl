onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider tb_m_spi
add wave -noupdate /tb_m_spi/*

add wave -noupdate -divider m_spi
add wave -noupdate /tb_m_spi/m_spi/*

add wave -noupdate -divider s_spi
add wave -noupdate /tb_m_spi/s_spi/*


configure wave -signalnamewidth 1
