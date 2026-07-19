# Pre-create library directories (vlib on Windows needs parent dirs to exist)
file mkdir modelsim_lib

# Run Vivado-generated compilation
do {compile.do}

quit -f
