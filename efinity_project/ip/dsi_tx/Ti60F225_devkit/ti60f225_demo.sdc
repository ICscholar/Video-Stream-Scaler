# PLL Constraints
#################
create_clock -period 10.00 i_mipi_clk
create_clock -waveform {0.750 1.750} -period 2.00 i_mipi_txc_sclk
create_clock -waveform {0.250 1.250} -period 2.00 i_mipi_txd_sclk
create_clock -period 8.00 i_mipi_tx_pclk
create_clock -period 40.00 i_fb_clk
create_clock -period 8.00 i_sysclk
create_clock -period 16.00 i_sysclk_div_2


set_clock_groups -exclusive -group {i_sysclk} -group {jtag_inst1_TCK} -group {i_mipi_clk} -group {i_sysclk} -group {i_mipi_tx_pclk}
#set_clock_groups -exclusive -group {i_sysclk_div_2} -group {jtag_inst1_TCK}
#set_clock_groups -exclusive -group {i_sysclk_div_4} -group {jtag_inst1_TCK}

# GPIO Constraints
####################

# LVDS RX GPIO Constraints
############################

# LVDS Rx Constraints
####################

# LVDS Tx Constraints
####################


# MIPI TX Lane Constraints
############################
set_output_delay -clock i_mipi_tx_pclk -reference_pin [get_ports {i_mipi_tx_pclk~CLKOUT~218~274}] -max 0.360 [get_ports {mipi_dp_clk_HS_OUT[*]}]
set_output_delay -clock i_mipi_tx_pclk -reference_pin [get_ports {i_mipi_tx_pclk~CLKOUT~218~274}] -min 0.140 [get_ports {mipi_dp_clk_HS_OUT[*]}]
set_output_delay -clock i_mipi_tx_pclk -reference_pin [get_ports {i_mipi_tx_pclk~CLKOUT~218~274}] -max 0.300 [get_ports {mipi_dp_clk_RST}]
set_output_delay -clock i_mipi_tx_pclk -reference_pin [get_ports {i_mipi_tx_pclk~CLKOUT~218~274}] -min 0.140 [get_ports {mipi_dp_clk_RST}]
set_output_delay -clock i_mipi_tx_pclk -reference_pin [get_ports {i_mipi_tx_pclk~CLKOUT~218~300}] -max 0.360 [get_ports {mipi_dp_data0_HS_OUT[*]}]
set_output_delay -clock i_mipi_tx_pclk -reference_pin [get_ports {i_mipi_tx_pclk~CLKOUT~218~300}] -min 0.140 [get_ports {mipi_dp_data0_HS_OUT[*]}]
set_output_delay -clock i_mipi_tx_pclk -reference_pin [get_ports {i_mipi_tx_pclk~CLKOUT~218~300}] -max 0.300 [get_ports {mipi_dp_data0_RST}]
set_output_delay -clock i_mipi_tx_pclk -reference_pin [get_ports {i_mipi_tx_pclk~CLKOUT~218~300}] -min 0.140 [get_ports {mipi_dp_data0_RST}]
set_output_delay -clock i_mipi_tx_pclk -reference_pin [get_ports {i_mipi_tx_pclk~CLKOUT~218~286}] -max 0.360 [get_ports {mipi_dp_data1_HS_OUT[*]}]
set_output_delay -clock i_mipi_tx_pclk -reference_pin [get_ports {i_mipi_tx_pclk~CLKOUT~218~286}] -min 0.140 [get_ports {mipi_dp_data1_HS_OUT[*]}]
set_output_delay -clock i_mipi_tx_pclk -reference_pin [get_ports {i_mipi_tx_pclk~CLKOUT~218~286}] -max 0.300 [get_ports {mipi_dp_data1_RST}]
set_output_delay -clock i_mipi_tx_pclk -reference_pin [get_ports {i_mipi_tx_pclk~CLKOUT~218~286}] -min 0.140 [get_ports {mipi_dp_data1_RST}]
set_output_delay -clock i_mipi_tx_pclk -reference_pin [get_ports {i_mipi_tx_pclk~CLKOUT~218~261}] -max 0.360 [get_ports {mipi_dp_data2_HS_OUT[*]}]
set_output_delay -clock i_mipi_tx_pclk -reference_pin [get_ports {i_mipi_tx_pclk~CLKOUT~218~261}] -min 0.140 [get_ports {mipi_dp_data2_HS_OUT[*]}]
set_output_delay -clock i_mipi_tx_pclk -reference_pin [get_ports {i_mipi_tx_pclk~CLKOUT~218~261}] -max 0.300 [get_ports {mipi_dp_data2_RST}]
set_output_delay -clock i_mipi_tx_pclk -reference_pin [get_ports {i_mipi_tx_pclk~CLKOUT~218~261}] -min 0.140 [get_ports {mipi_dp_data2_RST}]
set_output_delay -clock i_mipi_tx_pclk -reference_pin [get_ports {i_mipi_tx_pclk~CLKOUT~218~251}] -max 0.360 [get_ports {mipi_dp_data3_HS_OUT[*]}]
set_output_delay -clock i_mipi_tx_pclk -reference_pin [get_ports {i_mipi_tx_pclk~CLKOUT~218~251}] -min 0.140 [get_ports {mipi_dp_data3_HS_OUT[*]}]
set_output_delay -clock i_mipi_tx_pclk -reference_pin [get_ports {i_mipi_tx_pclk~CLKOUT~218~251}] -max 0.300 [get_ports {mipi_dp_data3_RST}]
set_output_delay -clock i_mipi_tx_pclk -reference_pin [get_ports {i_mipi_tx_pclk~CLKOUT~218~251}] -min 0.140 [get_ports {mipi_dp_data3_RST}]

