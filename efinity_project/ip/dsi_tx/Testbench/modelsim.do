onerror {quit -f}
vlib work
vlog TI60F225_MIPI_dsi_tb.v
vlog data_pack.v
vlog vga_gen.v
vlog dual_clock_fifo.v
vlog true_dual_port_ram.v
vlog simple_dual_port_ram.v
vlog shift_reg.v
vlog panel_config.v
vlog -sv ./modelsim/dsi_tx.sv

vsim -t ps work.TI60F225_MIPI_dsi_tb
run -all