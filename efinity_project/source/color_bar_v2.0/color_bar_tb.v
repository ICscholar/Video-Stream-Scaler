`timescale  1ns /1ps
module color_bar_tb;

parameter	MAX_HRES		= 12'd1200;
parameter	MAX_VRES		= 12'd1920;
parameter	HSP				= 8'd8;
parameter	HBP				= 8'd46;
parameter	HFP				= 8'd44;
parameter	VSP				= 8'd8;
parameter	VBP				= 8'd32;
parameter	VFP				= 8'd177;

reg clk = 1'b0;
reg rst_n = 1'b0;
reg clk_div2 = 'd0;
reg clk_div4 = 'd0;
reg clk_div8 = 'd0;
always #10 clk = ~clk;
always #20 clk_div2 = ~clk_div2;
always #40 clk_div4 = ~clk_div4;
always #80 clk_div8 = ~clk_div8;

initial
begin
        #0
            rst_n = 0;
        # 100

            rst_n = 1;
end 

wire [7:0] r_data;
wire [7:0] g_data;
wire [7:0] b_data;
wire p_vs;
wire p_hs;
wire p_de;
wire rd_clk ;
reg [5:0]datatype = 6'h24; 
reg clk_sel = 2'd0;//2'd0 = div2;//2'd1 = div4;//2'd2 = div8
assign rd_clk = clk_sel == 2'd0 ? clk_div2 : (clk_sel == 2'd1 ? clk_div4:clk_div8);
always @( posedge clk )
begin
	case( datatype )
	6'h20: begin end 
	6'h21: begin end
	6'h22: begin end
	6'h23: begin end
	6'h24: begin clk_sel <= 2'd0; end 
	6'h28: begin end 
	6'h29: begin end 
	6'h2a: begin end 
	6'h2b: begin end 
	6'h2c: begin end 
	6'h2d: begin end 
	6'h18: begin end 
	6'h19: begin end 
	6'h1a: begin end 
	6'h1c: begin end 
	6'h1d: begin end 
	6'h1e: begin end 
	6'h1f: begin end 
	6'h12: begin end 
	6'h30: begin end 
	6'h13: begin end 
	default:;
	endcase
	
end 



	color_bar_rgb #(
			.HS_POLORY 		(1'b1		),
			.VS_POLORY 		(1'b1		),
			.H_FRONT_PORCH 	(HFP		),
			.H_SYNC 		(HSP		),
			.H_VALID 		(MAX_HRES	),
			.H_BACK_PORCH 	(HBP		),
			.V_FRONT_PORCH 	(VFP		),
			.V_SYNC 		(VSP		),
			.V_VALID 		(MAX_VRES	),
			.V_BACK_PORCH 	(VBP		),
			.TEST_MODE 		(2'b00		)
	)u_color_bar_rgb(
	/*i*/.clk	(clk),
	/*i*/.rst_n	(rst_n ),
	
	/*o*/.hs	(hs),
	/*o*/.vs	(vs),
	/*o*/.de	(de),
	/*O*/.h_cnt (h_cnt),
	/*O*/.v_cnt (v_cnt),
	/*o*/.rgb_r	(r_data),    //像素数据、红色分量
	/*o*/.rgb_g	(g_data),    //像素数据、绿色分量
	/*o*/.rgb_b (b_data)    //像素数据、蓝色分量
	
	);
	sep2par 
	#(
	  .SEP_DATA_WIDTH(27 ),
	  .SHIFT_WIDTH (2 )
	)
	sep2par_dut (
	  .din ({hs,vs,de,r_data, g_data, b_data} ),
	  .sync (sync ),
	  .wrclk (clk ),
	  .rdclk (rdclk ),
	  .dout  ( dout)
	);
 
// 	 ser2par_pixel #(
// .PIX_DATA_WIDTH (24 )
// 	 )u_ser2par_pixel(
// /*i*/.wr_clk			(clk),
// /*i*/.rst_n			(rst_n ),
// /*i*/.i_hs			(hs),
// /*i*/.i_vs			(vs),
// /*i*/.i_de			(de),
// /*i*/.pixel_num		(0),
// /*i*/.type			(6'h3e),
// /*i*/.i_data		({r_data, g_data, b_data}),
// /*o*/.o_data		(),
// /*O*/.o_vs			(p_vs),			
// /*O*/.o_hs			(p_hs),
// /*O*/.o_de			(p_de),

// /*i*/.rd_clk		(rd_clk)
// );

reg vs_r0 = 'd0;
assign pos_vs = {vs_r0,vs} == 2'b01;

wire [53:0] wdata;
 sep2par  #(
.SEP_DATA_WIDTH (27) ,
 .SHIFT_WIDTH (2)

 )u_sep2par(
/*i*/.din	({hs,vs,de,r_data, g_data, b_data}),
/*i*/.sync	(pos_vs),
/*i*/.wrclk	(clk),
/*i*/.rdclk	(rd_clk),
/*o*/.dout(wdata)
);
wire w_hs = wdata[26]; 
wire w_vs = wdata[25]; 
wire w_de = wdata[24];   

 timing_detec u_timing_detec(
    /*i*/.clk			(rd_clk ),
    /*i*/.rst_n			(),
    /*i*/.i_hs			(w_hs),
    /*i*/.i_vs			(w_vs),
    /*i*/.i_de			(w_de),
    /*i*/.i_vid			(),
    /*o*/.h_sync		(),
    /*o*/.h_back_porch	(),
    /*o*/.h_front_porch	(),
    /*o*/.h_active		(),
    /*o*/.v_active		(),
    /*o*/.v_sync		(),
    /*o*/.v_back_porch	(),
    /*o*/.v_front_porch ()
);


endmodule