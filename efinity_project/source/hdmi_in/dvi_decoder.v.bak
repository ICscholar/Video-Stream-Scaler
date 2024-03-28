`timescale 1ns / 1ps
//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//抿术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料
//版权承有，盗版必究
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           dvi_decoder
// Descriptions:        HDMI解码模块
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2020/5/8 9:30:00
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module dvi_decoder (
  input  wire clk_200m, 
  input  wire pclk,           // regenerated pixel clock
  input  wire [9:0] bdata,		// Blue data in
  input  wire [9:0] gdata,		// Green data in
  input  wire [9:0] rdata,		// Red data in
  input  wire rst_n,        // external reset input, e.g. reset button
  output reg  reset,          // rx reset
  output wire hsync,          // hsync data
  output wire vsync,          // vsync data
  output wire de,             // data enable  
  output wire [7:0] red,      // pixel data out
  output wire [7:0] green,    // pixel data out
  output wire [7:0] blue      // pixel data out  
  
  );    

//parameter define    
parameter kCtlTknCount = 300; //检测到控制字符的最低持续个数
parameter kTimeoutMs = 50;    //未检测到控制字符的最大时间间隔

//wire define       
wire de_b, de_g, de_r;
wire blue_rdy, green_rdy, red_rdy;  //数据准备好信号
wire blue_vld, green_vld, red_vld;  //数据有效信号

//*****************************************************
//**                    main code
//*****************************************************  

assign de = de_b;

//RX端的复位信号
always @(posedge pclk ) begin       
    reset <= ~rst_n;       
end

 
//HDMI红色数据解码模块 
tmds_decoder #(
  .kCtlTknCount (kCtlTknCount),  //检测到控制字符的最低持续个数
  .kTimeoutMs (kTimeoutMs),      //未检测到控制字符的最大时间间隔
  .kRefClkFrqMHz (200)           //参考时钟频率
) u_tmds_decoder_0(

    .arst           (reset),
    .pixelclk       (pclk),
    .refclk         (clk_200m),
    .prst           (~rst_n),
    .datain      		(rdata),
    .potherchrdy    ({blue_rdy,green_rdy}), 
    .potherchvld    ({blue_vld,green_vld}),    
    .palignerr      (),
    .pc0            (),
    .pc1            (),    
    .pmerdy         (red_rdy),
    .pmevld         (red_vld),   
    .pvde           (de_r),
    .pdatain        (red),       
    .peyesize       ()    
);

//HDMI蓝色数据解码模块 
tmds_decoder #(
  .kCtlTknCount (kCtlTknCount),  //检测到控制字符的最低持续个数
  .kTimeoutMs (kTimeoutMs),      //未检测到控制字符的最大时间间隔
  .kRefClkFrqMHz (200)           //参考时钟频率
) u_tmds_decoder_1(

    .arst           (reset),
    .pixelclk       (pclk),
    .refclk         (clk_200m),
    .prst           (~rst_n),
    .datain      		(bdata),
    .potherchrdy    ({red_rdy,green_rdy}),
    .potherchvld    ({red_vld,green_vld}),    
    .palignerr      (),
    .pc0            (hsync),
    .pc1            (vsync),    
    .pmerdy         (blue_rdy),
    .pmevld         (blue_vld),   
    .pvde           (de_b),
    .pdatain        (blue),        
    .peyesize       ()    
);

//HDMI绿色数据解码模块 
tmds_decoder #(
  .kCtlTknCount (kCtlTknCount),     //检测到控制字符的最低持续个数
  .kTimeoutMs (kTimeoutMs),         //未检测到控制字符的最大时间间隔
  .kRefClkFrqMHz (200)              //参考时钟频率
) u_tmds_decoder_2(

    .arst           (reset),
    .pixelclk       (pclk),
    .refclk         (clk_200m),
    .prst           (~rst_n),
    .datain      		(gdata),
    .potherchrdy    ({red_rdy,blue_rdy}),
    .potherchvld    ({red_vld,blue_vld}),    
    .palignerr      (),
    .pc0            (),
    .pc1            (),    
    .pmerdy         (green_rdy),
    .pmevld         (green_vld),   
    .pvde           (de_g),
    .pdatain        (green),       
    .peyesize       ()    
);

endmodule
