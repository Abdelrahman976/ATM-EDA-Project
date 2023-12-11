vlib work
vlog design.v testbench.v +cover
vsim -voptargs=+acc work.atm_tb -cover
add wave *
coverage save atm_tb.ucdb -onexit -du ATM
run -all