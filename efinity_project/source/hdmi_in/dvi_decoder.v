`timescale 1ns / 1ps
//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com 
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX����
//��Ȩ���У�����ؾ�
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           dvi_decoder
// Descriptions:        HDMI����ģ��
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
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
parameter kCtlTknCount = 300; //��⵽�����ַ�����ͳ�������
parameter kTimeoutMs = 50;    //δ��⵽�����ַ������ʱ����

//wire define       
wire de_b, de_g, de_r;
wire blue_rdy, green_rdy, red_rdy;  //����׼�����ź�
wire blue_vld, green_vld, red_vld;  //������Ч�ź�

//*****************************************************
//**                    main code
//*****************************************************  

assign de = de_b;

//RX�˵ĸ�λ�ź�
always @(posedge pclk ) begin       
    reset <= ~rst_n;       
end

 
//HDMI��ɫ���ݽ���ģ�� 
tmds_decoder #(
  .kCtlTknCount (kCtlTknCount),  //��⵽�����ַ�����ͳ�������
  .kTimeoutMs (kTimeoutMs)      //δ��⵽�����ַ������ʱ����
) u_tmds_decoder_0(

    .arst           (reset),
    .pixelclk       (pclk),
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

//HDMI��ɫ���ݽ���ģ�� 
tmds_decoder #(
  .kCtlTknCount (kCtlTknCount),  //��⵽�����ַ�����ͳ�������
  .kTimeoutMs (kTimeoutMs)      //δ��⵽�����ַ������ʱ����
) u_tmds_decoder_1(

    .arst           (reset),
    .pixelclk       (pclk),
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

//HDMI��ɫ���ݽ���ģ�� 
tmds_decoder #(
  .kCtlTknCount (kCtlTknCount),     //��⵽�����ַ�����ͳ�������
  .kTimeoutMs (kTimeoutMs)         //δ��⵽�����ַ������ʱ����
) u_tmds_decoder_2(

    .arst           (reset),
    .pixelclk       (pclk),
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
