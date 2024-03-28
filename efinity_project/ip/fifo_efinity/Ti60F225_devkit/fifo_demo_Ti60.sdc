create_clock -period 3.125 [get_ports pll_clkout_0]
create_clock -period 6.250 [get_ports pll_clkout_1]
create_clock -period 200   [get_ports led_clk]