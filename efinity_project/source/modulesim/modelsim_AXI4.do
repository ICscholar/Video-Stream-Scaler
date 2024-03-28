
vlib work

vlog  -sv efx_ddr3_soft_controller_tb.v
vlog +define+den4096Mb +define+x16 -sv ddr3.v
vlog  efx_iddr.v
vlog  efx_oddr.v

vlog  ./example_top.v
vlog  ./memory_checker_axi.v
vlog  ./efx_ddr3_axi.v
vlog  ./../soft_ddr3/Ddr_Ctrl_Sc_Fifo.v
vlog  ./efx_srl8.v

vlog  ./efx_ddr3_soft_controller.v

vsim -t ps work.efx_ddr3_soft_controller_tb


run -all
