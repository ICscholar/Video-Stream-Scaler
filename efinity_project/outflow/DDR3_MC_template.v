
// Efinity Top-level template
// Version: 2023.1.150.5.11
// Date: 2023-11-14 13:01

// Copyright (C) 2017 - 2023 Efinix Inc. All rights reserved.

// This file may be used as a starting point for Efinity synthesis top-level target.
// The port list here matches what is expected by Efinity constraint files generated
// by the Efinity Interface Designer.

// To use this:
//     #1)  Save this file with a different name to a different directory, where source files are kept.
//              Example: you may wish to save as F:\Project\yls\Project3\uart_showchar_fillbrank_updown2\efinity_project\DDR3_MC.v
//     #2)  Add the newly saved file into Efinity project as design file
//     #3)  Edit the top level entity in Efinity project to:  DDR3_MC
//     #4)  Insert design content.


module DDR3_MC
(
  input nrst,
  input uart_rx,
  input DDR3_PLL_CLKOUT4,
  input DDR3_PLL_LOCK,
  input SYS_PLL_LOCK,
  input hdmi_rx_pll_LOCKED,
  input i_mipi_tx_pll_locked,
  input twd_clk,
  input tac_clk,
  input tdqss_clk,
  input mipi_fb,
  input i_mipi_txd_sclk,
  input core_clk,
  input rxc1,
  input rxc,
  input sys_clk,
  input clk_10m,
  input clk_25m,
  input hdmi_rx_fast_clk,
  input i_mipi_tx_pclk,
  input hdmi_rx_slow_clk,
  input hdmi_rx_slow_clk_2x,
  input hdmi_tx_fast_clk,
  input i_mipi_txc_sclk,
  input i_sysclk_div_2,
  input osc_clk,
  input clk_125m,
  input jtag_inst1_CAPTURE,
  input jtag_inst1_DRCK,
  input jtag_inst1_RESET,
  input jtag_inst1_RUNTEST,
  input jtag_inst1_SEL,
  input jtag_inst1_SHIFT,
  input jtag_inst1_TCK,
  input jtag_inst1_TDI,
  input jtag_inst1_TMS,
  input jtag_inst1_UPDATE,
  input hdmi_rx_clk_RX_DATA,
  input [9:0] hdmi_rx_d0_RX_DATA,
  input [9:0] hdmi_rx_d1_RX_DATA,
  input [9:0] hdmi_rx_d2_RX_DATA,
  input FPGA_HDMI_SCL_IN,
  input FPGA_HDMI_SDA_IN,
  input HDMI_5V_N,
  input [15:0] i_dq_hi,
  input [15:0] i_dq_lo,
  input [1:0] i_dqs_hi,
  input [1:0] i_dqs_lo,
  input mdio_i,
  input mdio_io1_IN,
  input rx_dv_HI,
  input rx_dv_LO,
  input rx_dv1_HI,
  input rx_dv1_LO,
  input [3:0] rxd1_HI,
  input [3:0] rxd1_LO,
  input [3:0] rxd_hi_i,
  input [3:0] rxd_lo_i,
  output LCD_POWER,
  output [1:0] b_led,
  output o_lcd_rstn,
  output phy_rst_n,
  output phy_rst_n1,
  output uart_tx,
  output DDR3_PLL_RSTN,
  output [2:0] shift,
  output shift_ena,
  output [4:0] shift_sel,
  output SYS_PLL_RSTN,
  output hdmi_rx_pll_RSTN,
  output o_mipi_pll_rstn,
  output jtag_inst1_TDO,
  output hdmi_rx_clk_RX_ENA,
  output hdmi_rx_d0_RX_RST,
  output hdmi_rx_d0_RX_ENA,
  output hdmi_rx_d1_RX_RST,
  output hdmi_rx_d1_RX_ENA,
  output hdmi_rx_d2_RX_RST,
  output hdmi_rx_d2_RX_ENA,
  output FPGA_HDMI_SCL_OUT,
  output FPGA_HDMI_SCL_OE,
  output FPGA_HDMI_SDA_OUT,
  output FPGA_HDMI_SDA_OE,
  output HPD_N,
  output [15:0] addr,
  output [2:0] ba,
  output cas,
  output cke,
  output cs,
  output [1:0] o_dm_hi,
  output [1:0] o_dm_lo,
  output [15:0] o_dq_hi,
  output [15:0] o_dq_lo,
  output [15:0] o_dq_oe,
  output [1:0] o_dqs_hi,
  output [1:0] o_dqs_lo,
  output [1:0] o_dqs_oe,
  output [1:0] o_dqs_n_oe,
  output hdmi_tx_clk_n_HI,
  output hdmi_tx_clk_n_LO,
  output hdmi_tx_clk_p_HI,
  output hdmi_tx_clk_p_LO,
  output [2:0] hdmi_tx_data_n_HI,
  output [2:0] hdmi_tx_data_n_LO,
  output [2:0] hdmi_tx_data_p_HI,
  output [2:0] hdmi_tx_data_p_LO,
  output mdc_o_HI,
  output mdc_o_LO,
  output mdc_o1_HI,
  output mdc_o1_LO,
  output mdio_o,
  output mdio_oe,
  output mdio_io1_OUT,
  output mdio_io1_OE,
  output odt,
  output ras,
  output reset,
  output tx_en_o_HI,
  output tx_en_o_LO,
  output tx_en_o1_HI,
  output tx_en_o1_LO,
  output txc_hi_o,
  output txc_lo_o,
  output txc1_HI,
  output txc1_LO,
  output [3:0] txd1_HI,
  output [3:0] txd1_LO,
  output [3:0] txd_hi_o,
  output [3:0] txd_lo_o,
  output we,
  output mipi_dp_clk_HS_OE,
  output [7:0] mipi_dp_clk_HS_OUT,
  output mipi_dp_clk_LP_N_OE,
  output mipi_dp_clk_LP_N_OUT,
  output mipi_dp_clk_LP_P_OE,
  output mipi_dp_clk_LP_P_OUT,
  output mipi_dp_clk_RST,
  output mipi_dp_data0_HS_OE,
  output [7:0] mipi_dp_data0_HS_OUT,
  output mipi_dp_data0_LP_N_OE,
  output mipi_dp_data0_LP_N_OUT,
  output mipi_dp_data0_LP_P_OE,
  output mipi_dp_data0_LP_P_OUT,
  output mipi_dp_data0_RST,
  output mipi_dp_data1_HS_OE,
  output [7:0] mipi_dp_data1_HS_OUT,
  output mipi_dp_data1_LP_N_OE,
  output mipi_dp_data1_LP_N_OUT,
  output mipi_dp_data1_LP_P_OE,
  output mipi_dp_data1_LP_P_OUT,
  output mipi_dp_data1_RST,
  output mipi_dp_data2_HS_OE,
  output [7:0] mipi_dp_data2_HS_OUT,
  output mipi_dp_data2_LP_N_OE,
  output mipi_dp_data2_LP_N_OUT,
  output mipi_dp_data2_LP_P_OE,
  output mipi_dp_data2_LP_P_OUT,
  output mipi_dp_data2_RST,
  output mipi_dp_data3_HS_OE,
  output [7:0] mipi_dp_data3_HS_OUT,
  output mipi_dp_data3_LP_N_OE,
  output mipi_dp_data3_LP_N_OUT,
  output mipi_dp_data3_LP_P_OE,
  output mipi_dp_data3_LP_P_OUT,
  output mipi_dp_data3_RST,
  output osc_en
);


endmodule

