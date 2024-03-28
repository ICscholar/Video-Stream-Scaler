#cd D:/FPGA_Prj/11_Ti60F225_DemoBoard/Prj_demo/01_Ti60_Soft_DDR3_Axi_demo_v6/efinity_project/source/modulesim


#Define vlib
vlib work

vlog  -sv efx_ddr3_soft_controller_tb.v
vlog +define+den4096Mb +define+x16 -sv ddr3.v
vlog  efx_iddr.v
vlog  efx_oddr.v
vlog  ./efx_srl8.v

vlog  ./example_top.v
vlog  ./memory_checker_axi.v
vlog  ./../soft_ddr3/efx_ddr3_axi.v
vlog  ./../soft_ddr3/Ddr_Ctrl_Sc_Fifo.v
vlog  ./efx_ddr3_soft_controller.v

vsim -t ps work.efx_ddr3_soft_controller_tb
 

#Run simulation
do wave.do
run 100us