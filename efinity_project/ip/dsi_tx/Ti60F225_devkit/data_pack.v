module data_pack
#(
	parameter PIXEL_BIT		= 5'd15,
	parameter PACK_BIT		= 8'd64,
	parameter FIFO_WIDTH	= 4'd12,
	parameter HSP			= 8'd2/2,           
	parameter HBP			= 8'd2/2,  	          
	parameter MAX_HRES		= 12'd1080/2,	           
	parameter HFP			= 8'd246/2,
	parameter VSP			= 8'd1,
	parameter VBP			= 8'd1,
	parameter MAX_VRES		= 12'd1920,
	parameter VFP			= 8'd32,
	parameter P_Cnt			= 3'd1
)
(
	input	in_pclk,
	input	out_pclk,
	input	in_rstn,
	
	input 	[FIFO_WIDTH-1:0]	in_x,
	input 	[FIFO_WIDTH-1:0]	in_y,
	input 						in_valid,
	input 						in_de,
	input 						in_hs,
	input 						in_vs,
	input	[PIXEL_BIT-1:0]		in_data,
	
	output 	[FIFO_WIDTH-1:0]	out_x,
	output 	[FIFO_WIDTH-1:0]	out_y,
	output 						out_valid,
	output 						out_de,
	output 						out_hs,
	output 						out_vs,
	output	[PACK_BIT-1:0]		out_data
);

parameter	PACK_DIV	= PACK_BIT / PIXEL_BIT;

/* VGA counter for the output display sync signals generator */
reg [FIFO_WIDTH-2:0]	r_x_total;
reg [FIFO_WIDTH-1:0]	r_out_x;
reg [FIFO_WIDTH-1:0]	r_in_x_1P;
reg [FIFO_WIDTH-1:0]	r_in_x_2P;
reg [3:0] 				r_pcnt;
reg [3:0] 				r_pcnt_1P;
reg [3:0] 				r_pcnt_2P;
reg [3:0] 				r_pcnt_3P;		
reg 					r_in_vs_1P;
reg 					r_in_hs_1P;
reg 					r_in_de_1P;
reg 					r_in_vs_2P;
reg 					r_in_hs_2P;
reg 					r_in_de_2P;
reg 					r_in_vs_3P;
reg 					r_in_hs_3P;
reg 					r_in_de_3P;
reg	[1:0]				r_line_start;
reg	[1:0]				r_line_end;
reg						r_line_end_1P;
reg						r_line_end_2P;
reg						r_out_vs_1P;
reg						r_out_vs_2P;
reg						r_out_vs_3P;
reg						r_out_vs_4P;
reg						r_out_vs_5P;
reg						r_out_vs_6P;
reg						r_out_hs_1P;
reg						r_out_hs_2P;
reg						r_out_hs_3P;
reg						r_out_hs_4P;
reg						r_out_hs_5P;
reg						r_out_hs_6P;
reg						r_out_de;
reg						r_out_de_1P;
reg						r_out_de_2P;
reg						r_out_de_3P;
reg						r_out_de_4P;
reg						r_out_valid;
reg						r_out_valid_1P;
reg						r_out_valid_2P;
reg						r_out_valid_3P;
reg						r_out_valid_4P;
reg	[FIFO_WIDTH-1:0]	r_in_y_4P;
reg	[FIFO_WIDTH-1:0]	r_out_x_1P;
reg	[FIFO_WIDTH-1:0]	r_out_x_2P;
reg	[FIFO_WIDTH-1:0]	r_out_x_3P;
reg	[FIFO_WIDTH-1:0]	r_out_x_4P;
reg	[FIFO_WIDTH-1:0]	r_out_x_5P;
reg	[FIFO_WIDTH-1:0]	r_out_x_6P;
reg	[FIFO_WIDTH-1:0]	r_out_x_7P;
reg	[FIFO_WIDTH-1:0]	r_out_x_8P;
reg	[FIFO_WIDTH-1:0]	r_out_y_4P;
reg	[PACK_BIT-1:0]		r_out_data_3P;
reg	[PACK_BIT-1:0]		r_out_data_4P;
reg						r_de_1P;
reg						r_de_2P;
reg 					r_pack_de_1P;
reg 					r_pack_de_2P;
reg 					r_final_de;	
reg 					r_final_de_1P;	
reg 					r_final_de_2P;
reg 					r_final_vs_1P;	
reg 					r_final_vs_2P;
reg 					r_final_hs_1P;	
reg 					r_final_hs_2P;
reg 					r_final_valid_1P;
reg 					r_final_valid_2P;
reg 					r_final_start;
reg	[1:0]				r_final_end;
reg 					r_final_end_1P;
reg 					r_final_end_2P;
reg 					r_final_end_3P;
reg 					r_final_end_4P;
reg						r_per_de_1P;
reg						r_per_de_2P;
reg	[FIFO_WIDTH-1:0]	r_final_x;
reg	[FIFO_WIDTH-1:0]	r_final_x_1P;
reg	[FIFO_WIDTH-1:0]	r_final_x_2P;		
reg	[FIFO_WIDTH-1:0]	r_final_y;		
reg	[FIFO_WIDTH-1:0]	r_final_y_1P;
reg	[FIFO_WIDTH-1:0]	r_final_y_2P;
reg						r_gen_rstn;
reg						r_frame_start;

wire					w_vs;
wire					w_hs;
wire					w_de;
wire					w_out_hs;
wire					w_out_vs;
wire					w_out_de;
wire[PIXEL_BIT-1:0]		w_out_data;
wire					w_per_de;

wire 	[11:0]w_vga_x;
wire 	[11:0]w_vga_y;
wire	w_vga_hs;
wire	w_vga_vs;
wire	w_vga_de;
wire	w_vga_valid;

/* Video generation */
vga_gen
#(
	.H_SyncPulse	(HSP),
	.H_BackPorch	(HBP),
	.H_ActivePix	(MAX_HRES),
	.H_FrontPorch	(HFP),
	.V_SyncPulse	(VSP),
	.V_BackPorch	(VBP),
	.V_ActivePix	(MAX_VRES),
	.V_FrontPorch	(VFP),
	.P_Cnt			(3'd1)
)
inst_vga_gen
(
	.in_pclk	(out_pclk	),
	.in_rstn	(r_gen_rstn	),
	
	.out_hs		(w_vga_hs	),
	.out_vs		(w_vga_vs	),
	.out_de		(w_vga_de	),
	.out_valid	(w_vga_valid),
	.out_x		(w_vga_x	),
	.out_y		(w_vga_y	)
);

/* VGA counter for the output display sync signals generator */
/* r_x_cnt for HSYNC and DEN */  
always @ (posedge in_pclk)
begin
	if(~in_rstn)
	begin    
		r_x_total		<= {(FIFO_WIDTH-1){1'b0}};
		r_out_x			<= {FIFO_WIDTH{1'b0}};
		r_in_x_1P		<= {FIFO_WIDTH{1'b0}};
		r_in_x_2P		<= {FIFO_WIDTH{1'b0}};
		r_in_y_4P		<= {FIFO_WIDTH{1'b0}};
		r_out_x_1P		<= {FIFO_WIDTH{1'b0}};
		r_out_x_2P		<= {FIFO_WIDTH{1'b0}};
		r_out_x_3P		<= {FIFO_WIDTH{1'b0}};
		r_out_x_4P		<= {FIFO_WIDTH{1'b0}};
		r_out_x_5P		<= {FIFO_WIDTH{1'b0}};
		r_out_x_6P		<= {FIFO_WIDTH{1'b0}};
		r_out_x_7P		<= {FIFO_WIDTH{1'b0}};
		r_out_x_8P		<= {FIFO_WIDTH{1'b0}};
		r_out_y_4P		<= {FIFO_WIDTH{1'b0}};
		r_out_data_3P	<= {PACK_BIT{1'b0}};
		r_out_data_4P	<= {PACK_BIT{1'b0}};
		r_pcnt			<= 4'b0;
		r_in_vs_1P		<= 1'b0;
		r_in_hs_1P		<= 1'b0;
		r_in_de_1P		<= 1'b0;
		r_in_vs_2P		<= 1'b0;
		r_in_hs_2P		<= 1'b0;
		r_in_de_2P		<= 1'b0;
		r_in_vs_3P		<= 1'b0;
		r_in_hs_3P		<= 1'b0;
		r_in_de_3P		<= 1'b0;
		r_line_start	<= 2'b0;
		r_line_end		<= 2'b0;
		r_line_end_1P	<= 1'b0;
		r_line_end_2P	<= 1'b0;
		r_out_vs_1P		<= 1'b0;
		r_out_vs_2P		<= 1'b0;
		r_out_vs_3P		<= 1'b0;
		r_out_vs_4P		<= 1'b0;
		r_out_vs_5P		<= 1'b0;
		r_out_vs_6P		<= 1'b0;
	    r_out_hs_1P		<= 1'b0;
	    r_out_hs_2P		<= 1'b0;
	    r_out_hs_3P		<= 1'b0;
	    r_out_hs_4P		<= 1'b0;
	    r_out_hs_5P		<= 1'b0;
	    r_out_hs_6P		<= 1'b0;
	    r_out_de		<= 1'b0;
	    r_out_de_1P		<= 1'b0;
		r_out_de_2P		<= 1'b0;
		r_out_de_3P		<= 1'b0;
		r_out_de_4P		<= 1'b0;
		r_out_valid		<= 1'b0;
		r_out_valid_1P	<= 1'b0;
		r_out_valid_2P	<= 1'b0;
		r_out_valid_3P	<= 1'b0;
		r_out_valid_4P	<= 1'b0;
		r_pcnt_1P		<= 4'b0;
		r_pcnt_2P		<= 4'b0;
		r_pcnt_3P		<= 4'b0;
		r_de_1P			<= 1'b0;
		r_de_2P			<= 1'b0;
		r_gen_rstn		<= 1'b0;
		r_frame_start	<= 1'b0;
	end	
	else
	begin
		r_in_vs_1P	<= in_vs;
		r_in_hs_1P	<= in_hs;
		r_in_de_1P	<= in_de;
		r_in_vs_2P	<= r_in_vs_1P;
		r_in_hs_2P	<= r_in_hs_1P;
		r_in_de_2P	<= r_in_de_1P;
		r_in_vs_3P	<= r_in_vs_2P;
		r_in_hs_3P	<= r_in_hs_2P;
		r_in_de_3P	<= r_in_de_2P;
		
		
		
		r_in_x_1P	<= in_x;
		r_in_x_2P	<= r_in_x_1P;
		if (r_line_end_2P)
		begin
			r_de_1P		<= w_de;
			r_out_vs_1P	<= w_vs;
			r_out_hs_1P	<= w_hs;
		end
		r_de_2P			<= r_de_1P;		
		r_out_vs_2P		<= r_out_vs_1P;
		r_out_vs_3P		<= r_out_vs_2P;
		r_out_vs_4P		<= r_out_vs_3P;
		r_out_vs_5P		<= r_out_vs_4P;
		r_out_vs_6P		<= r_out_vs_5P;		
	    r_out_hs_2P		<= r_out_hs_1P;
	    r_out_hs_3P		<= r_out_hs_2P;
	    r_out_hs_4P		<= r_out_hs_3P;
	    r_out_hs_5P		<= r_out_hs_4P;
	    r_out_hs_6P		<= r_out_hs_5P;
	    r_out_de_1P		<= r_out_de;
		r_out_de_2P		<= r_out_de_1P;
		r_out_de_3P		<= r_out_de_2P;
		r_out_de_4P		<= r_out_de_3P;
		r_out_valid_1P	<= r_out_valid;
		r_out_valid_2P	<= r_out_valid_1P;
		r_out_valid_3P	<= r_out_valid_2P;
		r_out_valid_4P	<= r_out_valid_3P;
		r_pcnt_1P		<= r_pcnt;
		r_pcnt_2P		<= r_pcnt_1P;
		r_pcnt_3P		<= r_pcnt_2P;
		r_out_x_1P		<= (r_out_x * PACK_DIV + r_pcnt) / PACK_DIV;// * PACK_DIV + r_pcnt;		
		r_out_x_2P		<= r_out_x_1P;
		r_out_x_3P		<= r_out_x_2P;
		r_out_x_4P		<= r_out_x_3P;
		r_out_x_5P		<= r_out_x_4P;
		r_out_x_6P		<= r_out_x_5P;
		r_out_x_7P		<= r_out_x_6P;
		r_out_x_8P		<= r_out_x_7P;
		r_line_end_1P	<= r_line_end[1];
		r_line_end_2P	<= r_line_end_1P;
		
		if (r_in_de_1P && ~r_in_de_2P && ~r_line_start[1])
			r_line_start	<= r_line_start + 1'b1;
			
		if (~r_in_de_1P && r_in_de_2P && ~r_line_end[1])
		begin
			r_line_end	<= r_line_end + 1'b1;
			r_x_total	<= r_in_x_2P / PACK_DIV + 1;
		end
		
		if (r_de_1P && ~r_de_2P)
			r_out_de	<= 1'b1;
			
		if (r_out_de)
		begin
			if (r_pcnt == (PACK_DIV - 1'b1))
			begin
				r_pcnt 		<= 2'b0;
				r_out_x		<= r_out_x + 1'b1;
			end
			else
				r_pcnt 		<= r_pcnt + 1'b1;
			
			if (r_pcnt_2P == (PACK_DIV - 1'b1))				
				r_out_valid	<= 1'b1;
			else
				r_out_valid	<= 1'b0;
			
			if (r_out_x > r_x_total)
			begin
				r_out_de	<= 1'b0;
				r_out_x		<= {FIFO_WIDTH{1'b0}};
			end
		end
		else
		begin
			r_pcnt 		<= 2'b0;
			r_out_valid	<= 1'b0;
		end
		
		if (r_pcnt_3P == (PACK_DIV - 1'b1))
			r_out_data_4P	<= r_out_data_3P;
			
		r_out_data_3P[PIXEL_BIT*(PACK_DIV-1)-1:0]	<= r_out_data_3P[PIXEL_BIT*(PACK_DIV)-1:PIXEL_BIT];
		r_out_data_3P[PIXEL_BIT*(PACK_DIV)-1:PIXEL_BIT*(PACK_DIV-1)]	<= w_out_data;
		
		if (~r_out_de_3P && r_out_de_4P)
			r_out_y_4P	<= r_out_y_4P + 1'b1;
		
		if (~r_out_vs_3P)
			r_out_y_4P	<= {FIFO_WIDTH{1'b0}};
		
		if (~r_in_vs_1P && r_in_vs_2P)
			r_frame_start	<= 1'b1;
		
		if (r_frame_start)
		begin
			if (~r_in_hs_1P && r_in_hs_2P)
				r_gen_rstn	<= 1'b1;
		end
	end
end

always @ (posedge out_pclk)
begin
	if(~in_rstn)
	begin   
		r_pack_de_1P 	<= 1'b0;
		r_pack_de_2P 	<= 1'b0;
		r_final_de		<= 1'b0;
		r_final_de_1P	<= 1'b0;		
		r_final_de_2P	<= 1'b0;	
		r_final_vs_1P	<= 1'b0;		
		r_final_vs_2P	<= 1'b0;	
		r_final_hs_1P	<= 1'b0;		
		r_final_hs_2P	<= 1'b0;	
		r_final_valid_1P<= 1'b0;		
		r_final_valid_2P<= 1'b0;
		r_final_start	<= 1'b0;
		r_final_end		<= 2'b0;
		r_final_end_1P	<= 1'b0;
		r_final_end_2P	<= 1'b0;
		r_final_end_3P	<= 1'b0;
		r_final_end_4P	<= 1'b0;
		r_per_de_1P		<= 1'b0;
		r_per_de_2P		<= 1'b0;
		r_final_x		<= {FIFO_WIDTH{1'b0}};
		r_final_x_1P	<= {FIFO_WIDTH{1'b0}};
		r_final_x_2P	<= {FIFO_WIDTH{1'b0}};		
		r_final_y		<= {FIFO_WIDTH{1'b0}};	
		r_final_y_1P	<= {FIFO_WIDTH{1'b0}};
		r_final_y_2P	<= {FIFO_WIDTH{1'b0}};
	end
	else
	begin
		r_pack_de_1P 	<= w_out_de;
		r_pack_de_2P 	<= r_pack_de_1P;
		r_final_vs_1P	<= w_vga_vs;		
		r_final_vs_2P	<= r_final_vs_1P;
		r_final_hs_1P	<= w_vga_hs;		
		r_final_hs_2P	<= r_final_hs_1P;
		r_final_de_1P	<= w_vga_de;		
		r_final_de_2P	<= r_final_de_1P;
		r_final_x_1P	<= w_vga_x;
		r_final_x_2P	<= r_final_x_1P;		
		r_final_y_1P	<= w_vga_y;
		r_final_y_2P	<= r_final_y_1P;
		r_final_valid_1P<= w_vga_valid;		
		r_final_valid_2P<= r_final_valid_1P;		
		r_final_end_1P	<= r_final_end[1];
		r_final_end_2P	<= r_final_end_1P;
		r_final_end_3P	<= r_final_end_2P;
		r_final_end_4P	<= r_final_end_3P;
		
		if (r_final_end_2P)
			r_per_de_1P		<= w_per_de;
		r_per_de_2P		<= r_per_de_1P;
		
		if (r_per_de_1P && ~r_per_de_2P)
			r_final_de	<= 1'b1;
		
		if (~r_pack_de_1P && r_pack_de_2P && ~r_final_end[1])
			r_final_end	<= r_final_end + 1'b1;
		
		if (r_pack_de_1P && ~r_pack_de_2P)
			r_final_start	<= 1'b1;
		
		if (r_final_de)
		begin
			if (r_final_x == r_x_total - 1)
			begin
				r_final_de	<= 1'b0;
				r_final_x		<= {FIFO_WIDTH{1'b0}};
			end
			else
				r_final_x	<= r_final_x + 1'b1;
		end
		
		if (~r_final_de_1P && r_final_de_2P)
			r_final_y	<= r_final_y + 1'b1;
			
		if (~w_out_vs)
			r_final_y	<= {FIFO_WIDTH{1'b0}};
		
		
	end
end

/* 1 line delay */
dual_clock_fifo
#(	
	.DATA_WIDTH(3),
    .ADDR_WIDTH(FIFO_WIDTH)
) 
dual_clock_fifo_in0 
(
	.i_arst 	(~in_rstn),
	.i_wclk 	(in_pclk),
	.i_we 		(r_line_start[1]),
	.i_wdata 	({in_vs, in_hs, r_in_de_1P}),  
	.i_rclk 	(in_pclk),  
	.i_re 		(r_line_end[1]),  
	.o_rdata 	({w_vs, w_hs, w_de})
);

//dual_clock_fifo
//#(	
//	.DATA_WIDTH(2),
//    .ADDR_WIDTH(FIFO_WIDTH)
//) 
//dual_clock_fifo_in1 
//(
//	.i_arst 	(~in_rstn),
//	.i_wclk 	(out_pclk),
//	.i_we 		(r_line_start[1]),
//	.i_wdata 	({in_vs, in_hs}),  
//	.i_rclk 	(out_pclk),  
//	.i_re 		(r_final_end_4P),  
//	.o_rdata 	({out_vs, out_hs})
//);

dual_clock_fifo
#(	
	.DATA_WIDTH(1),
    .ADDR_WIDTH(FIFO_WIDTH)
) 
dual_clock_fifo_in2 
(
	.i_arst 	(~in_rstn),
	.i_wclk 	(out_pclk),
	.i_we 		(r_line_start[1]),
	.i_wdata 	(in_de),  
	.i_rclk 	(out_pclk),  
	.i_re 		(r_final_end[1]),  
	.o_rdata 	(w_per_de)
);

shift_reg
#(
	.D_WIDTH(2),
	.TAPE(7 + PACK_DIV)
)
inst_shift_reg_00
(                                                                    
	.i_arst	(~in_rstn),                                               
	.i_clk	(in_pclk),
	.i_en	(1'b1),

	.i_d({w_vs, w_hs}),
	.o_q({w_out_vs, w_out_hs})                  	
);

shift_reg
#(
	.D_WIDTH(1),
	.TAPE(PACK_DIV - 1)
)
inst_shift_reg_01
(                                                                    
	.i_arst	(~in_rstn),                                               
	.i_clk	(in_pclk),
	.i_en	(1'b1),

	.i_d(r_out_de_4P),
	.o_q(w_out_de)                  	
);

/* 1 line buffer */
simple_dual_port_ram
#(
	. DATA_WIDTH   	(PIXEL_BIT),
	. ADDR_WIDTH	(FIFO_WIDTH)
)
inst_line_buffer_00
(
	.wclk	(in_pclk	),
	.we		(in_valid	),
	.waddr	(in_x		),
	.wdata	(in_data	),
		
	.rclk	(in_pclk	),
	.re		(r_out_de	),
	.raddr	({r_out_x * PACK_DIV + r_pcnt}),
	.rdata	(w_out_data	)
);

/* 1 line buffer */
simple_dual_port_ram
#(
	. DATA_WIDTH   	(PACK_BIT),
	. ADDR_WIDTH	(FIFO_WIDTH)
)
inst_line_buffer_01
(
	.wclk	(in_pclk		),
	.we		(r_out_valid_1P	),
	.waddr	(r_out_x_4P		),
	.wdata	(r_out_data_4P	),
		
	.rclk	(out_pclk	),
	.re		(w_vga_valid),
	.raddr	(w_vga_x	),
	.rdata	(out_data	)
);

assign	out_x		= r_final_x_2P;
assign	out_y		= r_final_y_2P;
assign	out_valid	= r_final_de_2P;
assign	out_de		= r_final_de_2P;
assign	out_vs		= r_final_vs_2P;
assign	out_hs		= r_final_hs_2P;

endmodule
