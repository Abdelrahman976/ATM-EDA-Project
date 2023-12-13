vlib work
vlog design.v testbench.v +cover
vsim -voptargs=+acc work.atm_tb -cover -msgmode both
add wave *
coverage save atm_tb.ucdb -onexit -du ATM
run -all