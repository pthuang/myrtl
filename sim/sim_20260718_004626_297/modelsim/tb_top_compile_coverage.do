# Pre-create library directories (vlib on Windows needs parent dirs to exist)
file mkdir modelsim_lib

# Run coverage-instrumented compilation
do {compile_coverage.do}

quit -f
