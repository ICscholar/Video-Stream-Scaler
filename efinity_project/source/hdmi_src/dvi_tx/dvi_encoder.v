`timescale 1 ps / 1ps
module dvi_encoder
(
	input           pixelclk,       // system clock
	input           pixelclk5x,     // system clock x5
	input           rstin,          // reset
	input[7:0]      blue_din,       // Blue data in
	input[7:0]      green_din,      // Green data in
	input[7:0]      red_din,        // Red data in
	input           hsync,          // hsync data
	input           vsync,          // vsync data
	input           de,             // data enable
	output [2:0]	dataout_h,
	output [2:0]	dataout_l,
	output			clk_h,
	output			clk_l,
	output [2:0] data_p_h,
	output [2:0] data_p_l,
	output 		 clk_p_h ,
	output 		 clk_p_l ,
	output [2:0] data_n_h,
	output [2:0] data_n_l,
	output 		 clk_n_h ,
	output 		 clk_n_l 
);

wire    [9:0]   red ;
wire    [9:0]   green ;
wire    [9:0]   blue ;

encode encb (
	.clkin      (pixelclk),
	.rstin      (rstin),
	.din        (blue_din),
	.c0         (hsync),
	.c1         (vsync),
	.de         (de),
	.dout       (blue)) ;

encode encr (
	.clkin      (pixelclk),
	.rstin      (rstin),
	.din        (green_din),
	.c0         (1'b0),
	.c1         (1'b0),
	.de         (de),
	.dout       (green)) ;

encode encg (
	.clkin      (pixelclk),
	.rstin      (rstin),
	.din        (red_din),
	.c0         (1'b0),
	.c1         (1'b0),
	.de         (de),
	.dout       (red)) ;

serdes_4b_10to1 serdes_4b_10to1_m0(
	.clk           (pixelclk        ),// clock input
	.clkx5         (pixelclk5x      ),// 5x clock input
	.data_b      (blue            ),// input data for serialisation
	.data_g      (green           ),// input data for serialisation
	.data_r      (red             ),// input data for serialisation
	.data_c      (10'b1111100000  ),// input data for serialisation
	// .dataout_h 	   (dataout_h 	),
	// .dataout_l 	   (dataout_l 	),
	// .clk_h 		   (clk_h 		),
	// .clk_l  	   (clk_l  		)

	.data_p_h	(data_p_h),
	.data_p_l	(data_p_l),
	.clk_p_h 	(clk_p_h ),
	.clk_p_l 	(clk_p_l ),
	.data_n_h	(data_n_h),
	.data_n_l	(data_n_l),
	.clk_n_h 	(clk_n_h ),
	.clk_n_l 	(clk_n_l )

	// .dataout_0_p   (tmds_data_p[0]  ),// out DDR data
	// .dataout_0_n   (tmds_data_n[0]  ),// out DDR data
	// .dataout_1_p   (tmds_data_p[1]  ),// out DDR data
	// .dataout_1_n   (tmds_data_n[1]  ),// out DDR data
	// .dataout_2_p   (tmds_data_p[2]  ),// out DDR data
	// .dataout_2_n   (tmds_data_n[2]  ),// out DDR data
	// .dataout_3_p   (tmds_clk_p      ),// out DDR data
	// .dataout_3_n   (tmds_clk_n      ) // out DDR data
  ) ; 

endmodule
