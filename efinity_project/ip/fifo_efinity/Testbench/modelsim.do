onerror {quit -f}
vlib work
vlog -sv fifo_tb.sv
vlog -f flist
vsim -t ps +notimingchecks -voptargs="+acc" work.fifo_tb
run -All
