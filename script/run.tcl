quit -sim

vlib ./lib/ 
vlib ./lib/work/ 

vmap work ./lib/work/

vlog -work work ./../design/*.sv
vlog -work work ./../sim/uart_tb.sv

vsim -voptargs=+acc work.uart_tb 

add wave -divider uart_tb 

add wave uart_tb/*

add wave -divider {uart}
add wave uart_tb/u_uart/*

run 500ns