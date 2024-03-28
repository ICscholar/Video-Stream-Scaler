/*******************************************************/
/****                                                  */
/****	本程序来自第三方，仅供参考，请勿传播、商用*****/
/****                                                  */
/*******************************************************/
/*
	计算公式：	
	R = 1.164(Y - 16) + 1.793(CR - 128)                   = 1.164Y           + 1.793CR - 248.128;
	G = 1.164(Y - 16) - 0.534(CR - 128) - 0.213(CB - 128) = 1.164Y - 0.213CB - 0.534CR + 76.992;
	B = 1.164(Y - 16) 		    + 2.115(CB - 128) = 1.164Y + 2.115CB           - 289.344;
	其中，时序在计算过程中完全没有用到
	输入到输出有三个clock的时延。
	第一级流水线计算所有乘法；
	第二级流水线计算所有加法，把正的和负的分开进行加法；
	第三级流水线计算最终的和，若为负数取0；
*/
`timescale 1ns/1ps
module	ycbcr_to_rgb(
	input	clk,
	input	wire[7 : 0]		i_y_8b,
	input	wire[7 : 0]		i_cb_8b,
	input	wire[7 : 0]		i_cr_8b,
	                				
	input	                i_h_sync,
	input	                i_v_sync,
	input	                i_data_en,
	
	output	wire[7 : 0]		o_r_8b,
	output	wire[7 : 0]		o_g_8b,
	output	wire[7 : 0]		o_b_8b,
	
	output	reg				o_h_sync,
	output	reg				o_v_sync,                                                                                                    
	output	reg				o_data_en                                                                                                   
);

/***************************************parameters*******************************************/
//multiply 256
parameter	para_1164_10b = 10'd297;	//1.160
parameter	para_1793_10b = 10'd459;	//1.793
parameter	para_0534_10b = 10'd137;	//0.535
parameter	para_0213_10b = 10'd54;		//0.211
parameter	para_2115_10b = 10'd541;	//2.113
parameter	para_248128_18b = 18'd63521;//248.128
parameter	para_76992_18b = 18'd19710; //76.992
parameter	para_289344_18b = 18'd74072;//289.344
/********************************************************************************************/

/***************************************signals**********************************************/
wire				sign_r;
wire				sign_g;
wire				sign_b;
reg[17 : 0]	mult_y_for_r_18b;
reg[17 : 0]	mult_y_for_g_18b;
reg[17 : 0]	mult_y_for_b_18b;

reg[17 : 0]	mult_cb_for_g_18b;
reg[17 : 0]	mult_cb_for_b_18b;

reg[17 : 0]	mult_cr_for_r_18b;
reg[17 : 0]	mult_cr_for_g_18b;

reg[17 : 0]	add_r_0_18b;
reg[17 : 0]	add_g_0_18b;
reg[17 : 0]	add_b_0_18b;

reg[17 : 0]	add_r_1_18b;
reg[17 : 0]	add_g_1_18b;
reg[17 : 0]	add_b_1_18b;

reg[17 : 0] result_r_18b;
reg[17 : 0]	result_g_18b;
reg[17 : 0]	result_b_18b;

reg			i_h_sync_delay_1;
reg			i_v_sync_delay_1;
reg			i_data_en_delay_1;

reg			i_h_sync_delay_2;
reg			i_v_sync_delay_2;
reg			i_data_en_delay_2;

/********************************************************************************************/

/***************************************initial**********************************************/
initial
begin
	mult_y_for_r_18b <= 18'd0;
	mult_y_for_g_18b <= 18'd0;
	mult_y_for_b_18b <= 18'd0;
	
	mult_cb_for_g_18b <= 18'd0;
	mult_cb_for_b_18b <= 18'd0;
	
	mult_cr_for_r_18b <= 18'd0;
	mult_cr_for_g_18b <= 18'd0;

	
	add_r_0_18b <= 18'd0;
	add_g_0_18b <= 18'd0;
	add_b_0_18b <= 18'd0;
	
	add_r_1_18b <= 18'd0;
	add_g_1_18b <= 18'd0;
	add_b_1_18b <= 18'd0;
	
	result_r_18b <= 18'd0;
	result_g_18b <= 18'd0;
	result_b_18b <= 18'd0;
	
	i_h_sync_delay_1 <= 1'd0;
	i_v_sync_delay_1 <= 1'd0;
	i_data_en_delay_1 <= 1'd0;
	
	i_h_sync_delay_2 <= 1'd0;
	i_v_sync_delay_2 <= 1'd0;
	i_data_en_delay_2 <= 1'd0;

	
	o_h_sync <= 1'd0;
	o_v_sync <= 1'd0;                                                                                                  
	o_data_en <= 1'd0;                                             	
end 
/********************************************************************************************/
    
/***************************************arithmetic*******************************************/
//LV1 pipeline : mult
always @ (posedge	clk)
begin
	mult_y_for_r_18b <= i_y_8b * para_1164_10b;
	mult_y_for_g_18b <= i_y_8b * para_1164_10b;
	mult_y_for_b_18b <= i_y_8b * para_1164_10b;
end

always @ (posedge	clk)
begin
	mult_cb_for_g_18b <= i_cb_8b * para_0213_10b;
	mult_cb_for_b_18b <= i_cb_8b * para_2115_10b;
end

always @ (posedge	clk)
begin
	mult_cr_for_r_18b <= i_cr_8b * para_1793_10b;
	mult_cr_for_g_18b <= i_cr_8b * para_0534_10b;
end
//LV2 pipeline : add
always @ (posedge	clk)
begin
	add_r_0_18b <= mult_y_for_r_18b + mult_cr_for_r_18b;
	add_r_1_18b <= para_248128_18b;
	add_g_0_18b <= mult_y_for_g_18b + para_76992_18b;
	add_g_1_18b <= mult_cb_for_g_18b + mult_cr_for_g_18b;
	add_b_0_18b <= mult_y_for_b_18b + mult_cb_for_b_18b;
	add_b_1_18b <= para_289344_18b;
end
//LV3 pipeline : y + cb + cr
assign	sign_r = (add_r_0_18b >= add_r_1_18b);
assign	sign_g = (add_g_0_18b >= add_g_1_18b);
assign	sign_b = (add_b_0_18b >= add_b_1_18b);
always @ (posedge	clk)
begin
	result_r_18b = sign_r ? (add_r_0_18b - add_r_1_18b) : 18'd0;
	result_g_18b = sign_g ? (add_g_0_18b - add_g_1_18b) : 18'd0;
	result_b_18b = sign_b ? (add_b_0_18b - add_b_1_18b) : 18'd0;
end

//output 溢出处理
assign	o_r_8b = (result_r_18b[17:16] == 2'b00) ? result_r_18b[15 : 8] : 8'hff;
assign	o_g_8b = (result_g_18b[17:16] == 2'b00) ? result_g_18b[15 : 8] : 8'hff;
assign	o_b_8b = (result_b_18b[17:16] == 2'b00) ? result_b_18b[15 : 8] : 8'hff;
/********************************************************************************************/

/***************************************timing***********************************************/
always @ (posedge	clk)
begin
	i_h_sync_delay_1 <= i_h_sync;
	i_v_sync_delay_1 <= i_v_sync;
	i_data_en_delay_1 <= i_data_en;

	i_h_sync_delay_2 <= i_h_sync_delay_1;
	i_v_sync_delay_2 <= i_v_sync_delay_1;
	i_data_en_delay_2 <= i_data_en_delay_1;

		
	o_h_sync <= i_h_sync_delay_2;
	o_v_sync <= i_v_sync_delay_2;
	o_data_en <= i_data_en_delay_2;
end
/********************************************************************************************/
endmodule