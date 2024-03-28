set TB_NAME color_bar_tb

#Define vlib
vlib work
vmap work work
#Compile user files

vlog  ./color_bar_rgb.v
vlog  ./color_bar_tb.v
vlog  ./ser2par_pixel.v
vlog  ./timing_detec.v

#Load the design.
#vsim -t ps +notimingchecks -gui -voptargs="+acc" work.$TB_NAME
vsim -t ps  -voptargs=+acc work.color_bar_tb

#Run simulation
do wave.do
run 100ms