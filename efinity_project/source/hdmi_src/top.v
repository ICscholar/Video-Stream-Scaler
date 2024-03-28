//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
//                                                                              //
//  Author: meisq                                                               //
//          msq@qq.com                                                          //
//          ALINX(shanghai) Technology Co.,Ltd                                  //
//          heijin                                                              //
//     WEB: http://www.alinx.cn/                                                //
//     BBS: http://www.heijin.org/                                              //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
// Copyright (c) 2017,ALINX(shanghai) Technology Co.,Ltd                        //
//                    All rights reserved                                       //
//                                                                              //
// This source file may be used and distributed without restriction provided    //
// that this copyright statement is not removed from the file and that any      //
// derivative work contains the original copyright notice and the associated    //
// disclaimer.                                                                  //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////

//================================================================================
//  Revision History:
//  Date          By            Revision    Change Description
//--------------------------------------------------------------------------------
//2017/7/20                    1.0          Original
//*******************************************************************************/
module top(
	input                       clk,
	input                       rst_n,
	//hdmi output        
	output                      tmds_clk_p,
	output                      tmds_clk_n,
	output[2:0]                 tmds_data_p,    //rgb
	output[2:0]                 tmds_data_n     //rgb
	
);

wire                            video_clk;
wire                            video_clk5x;
wire                            video_hs;
wire                            video_vs;
wire                            video_de;
wire[7:0]                       video_r;
wire[7:0]                       video_g;
wire[7:0]                       video_b;

wire                            osd_hs;
wire                            osd_vs;
wire                            osd_de;
wire[7:0]                       osd_r;
wire[7:0]                       osd_g;
wire[7:0]                       osd_b;


//generate video pixel clock
video_pll video_pll_m0(
	.inclk0(clk),
	.c0(video_clk),
	.c1(video_clk5x),
	);

color_bar color_bar_m0(
	.clk                   (video_clk                  ),
	.rst                   (~rst_n                     ),
	.hs                    (video_hs                   ),
	.vs                    (video_vs                   ),
	.de                    (video_de                   ),
	.rgb_r                 (video_r                    ),
	.rgb_g                 (video_g                    ),
	.rgb_b                 (video_b                    )
);
osd_display  osd_display_m0(
	.rst_n                 (rst_n                      ),
	.pclk                  (video_clk                  ),
	.i_hs                  (video_hs                   ),
	.i_vs                  (video_vs                   ),
	.i_de                  (video_de                   ),
	.i_data                ({video_r,video_g,video_b}  ),
	.o_hs                  (osd_hs                     ),
	.o_vs                  (osd_vs                     ),
	.o_de                  (osd_de                     ),
	.o_data                ({osd_r,osd_g,osd_b}        )
);

dvi_encoder dvi_encoder_m0
(
	.pixelclk      (video_clk          ),// system clock
	.pixelclk5x    (video_clk5x        ),// system clock x5
	.rstin         (~rst_n             ),// reset
	.blue_din      (osd_b              ),// Blue data in
	.green_din     (osd_g              ),// Green data in
	.red_din       (osd_r              ),// Red data in
	.hsync         (osd_hs             ),// hsync data
	.vsync         (osd_vs             ),// vsync data
	.de            (osd_de             ),// data enable
	.tmds_clk_p    (tmds_clk_p         ),
	.tmds_clk_n    (tmds_clk_n         ),
	.tmds_data_p   (tmds_data_p        ),//rgb
	.tmds_data_n   (tmds_data_n        ) //rgb
);
endmodule