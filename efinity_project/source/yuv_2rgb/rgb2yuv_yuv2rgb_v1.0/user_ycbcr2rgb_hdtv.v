module user_ycbcr2rgb_hdtv #(
	parameter BIT_PER_SYMBLE = 8
)(
input	wire							clk,

input	wire[3*BIT_PER_SYMBLE-1:0]	ycbcr_din,
input	wire						ycbcr_h_sync,
input	wire						ycbcr_v_sync,
input	wire						ycbcr_de,

output	reg	[3*BIT_PER_SYMBLE-1:0]	rgb_dout,
output	reg							rgb_h_sync,
output	reg							rgb_v_sync,
output	reg							rgb_de


);
//============================================================
//R = 1.164(Y-16) + 1.793(Cr - 128) = 1.164*Y + 1.793*Cr -(1.164*16+1.796*128)
//G = 1.164(Y-16) - 0.213(Cb - 128) - 0.534(Cr - 128) = 1.164*Y - 0.213*Cb - 0.534*Cr +(-1.164*16+0.213*128+0.534*128)
//B = 1.164(Y-16) + 2.115(Cb - 128) = 1.164*Y + 2.115*Cb +(-1.164*16-2.115*128)
//============================================================
wire	[7:0]	ycbcr_y = ycbcr_din[23:16];
wire	[7:0]	ycbcr_cr = ycbcr_din[15:8];
wire	[7:0]	ycbcr_cb = ycbcr_din[ 7:0];

reg	signed 	[17:0]	r_coe_y_mux = 'd0;
reg	signed 	[17:0]	r_coe_cr_mux = 'd0;

reg	signed 	[17:0]	g_coe_y_mux	='d0;
reg	signed 	[17:0]	g_coe_cb_mux = 'd0;
reg	signed 	[17:0]	g_coe_cr_mux = 'd0;

reg	signed	[17:0]	b_coe_y_mux	='d0;
reg	signed	[17:0]	b_coe_cb_mux = 'd0;

reg	h_sync_d1 = 'd0;
reg	v_sync_d1	= 'd0;
reg	de_d1 = 'd0;
//==========================================================
//
//==========================================================
always @( posedge clk )
begin
	r_coe_y_mux		<=	9'd256 * {1'b0,ycbcr_y};
	r_coe_cr_mux	<=	9'd359 * {1'b0,ycbcr_cr};
end

always @( posedge clk )
begin
	g_coe_y_mux		<=	9'd256 * {1'b0,ycbcr_y};
	g_coe_cb_mux	<=	-9'd88 *{1'b0,ycbcr_cb};
	g_coe_cr_mux	<=	-9'd183 * {1'b0,ycbcr_cr};
end

always @( posedge clk )
begin
	b_coe_y_mux		<=	9'd256 * {1'b0,ycbcr_y};
	b_coe_cb_mux 	<= 	9'd454 *{1'b0,ycbcr_cb};
end

always @( posedge clk )
begin
	h_sync_d1 	<= 	ycbcr_h_sync;
	v_sync_d1 	<= 	ycbcr_v_sync;
	de_d1		<=	ycbcr_de;
end
//==========================================================
//
//==========================================================
reg	signed	[17:0]	g_add = 'd0;
reg	signed	[17:0]	b_add = 'd0;
reg	signed	[17:0]	r_add = 'd0;
reg	h_sync_d2 = 'd0;
reg	v_sync_d2 = 'd0;
reg	de_d2 = 'd0;
always @( posedge clk )
begin
	r_add	<=	r_coe_y_mux + r_coe_cr_mux;
	g_add	<= 	g_coe_cb_mux + g_coe_cr_mux + g_coe_y_mux;
	b_add	<=	b_coe_cb_mux + b_coe_y_mux;
end
always @( posedge clk )
begin
	h_sync_d2 	<= 	h_sync_d1;
	v_sync_d2 	<= 	v_sync_d1;
	de_d2		<=	de_d1;
end

//==========================================================
//
//==========================================================
reg	signed	[17:0] 	const_r_add = 'd0;
reg	signed	[17:0] 	const_g_add = 'd0;
reg	signed	[17:0]	const_b_add = 'd0;
reg	h_sync_d3 = 'd0;
reg	v_sync_d3 = 'd0;
reg	de_d3 = 'd0;
always @( posedge clk )
begin
	const_r_add <= r_add + -18'd45941;
	const_g_add <= g_add + 18'd34678;
	const_b_add <= b_add + -18'd58065;
end
always @( posedge clk )
begin
	h_sync_d3 	<= 	h_sync_d2;
	v_sync_d3 	<= 	v_sync_d2;
	de_d3		<=	de_d2;
end
//==========================================================
//
//==========================================================
always @(posedge clk)
begin
/*r*/   if(const_r_add[17]) rgb_dout[23:16] <= 8'd0;
	else if(const_r_add[16]) rgb_dout[23:16] <=8'd255;
	else rgb_dout[23:16] <= const_r_add[15:8];
	
/*g*/   if(const_g_add[17]) rgb_dout[15:8] <= 8'd0;
	else if(const_g_add[16]) rgb_dout[15:8] <=8'd255;
	else rgb_dout[15:8] <= const_g_add[15:8];  
	
/*b*/   if(const_b_add[17]) rgb_dout[7:0] <= 8'd0;
	else if(const_b_add[16]) rgb_dout[7:0] <=8'd255;
	else rgb_dout[7:0] <= const_b_add[15:8];      
end
always @( posedge clk )
begin
	rgb_h_sync 	<= 	h_sync_d3;
	rgb_v_sync 	<= 	v_sync_d3;
	rgb_de		<=	de_d3;
end



endmodule
