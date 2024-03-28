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
// File name:           tmds_decoder
// Descriptions:        HDMI���ݽ���ģ��
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2020/5/8 9:30:00
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************

module tmds_decoder #(   
  parameter kCtlTknCount = 128,    //��⵽�����ַ�����ͳ�������
  parameter kTimeoutMs = 50       //δ��⵽�����ַ������ʱ����
)(
    input              arst        ,   
    input              pixelclk    ,   //TMDS clock x1 (CLKDIV)
    input              prst        ,   //Synchronous reset to restart lock procedure
    input   [9:0]      datain   	 ,   //TMDS data channel positive
    input   [1:0]      potherchrdy ,   //����2������ͬ������ź� 
    input   [1:0]      potherchvld ,   //����2������У׼����ź� 
    output             palignerr   ,   //У׼�����ź�
    output             pc0         ,   //�����ź�
    output             pc1         ,   //�����ź�
    output             pmerdy      ,   //����ͬ������ź� 
    output             pmevld      ,   //����У׼����ź�
    output             pvde        ,   //������Чʹ��
    output   [7:0]     pdatain     ,   //�����8bit��ɫ����
    output   [4:0]     peyesize        //������⵽�����ַ����ӳ�ֵ�Ĵ���

    );
    
//wire define 
wire                            pc0;           //�����ź�
wire                            pc1;           //�����ź�
wire                            pvde;          //������Чʹ�� 
wire  [7:0]                     pdatain;       //������8bit��ɫ����
wire  [4:0]                     peyesize;      //������⵽�����ַ����ӳ�ֵ�Ĵ���
wire  [9:0]                     pdatainbnd;    //ͬ�����10bit��������
wire  [9:0]                     pdatainraw;    //ת�����10bit��������
wire                            pmerdy_int;    //����ͬ������ź�
wire                            paligned;      //����У׼����ź�
wire                            palignerr_int; //У׼�����ź�
wire                            pbitslip;      //�ֶ����ƶ��ź�

//*****************************************************
//**                    main code
//***************************************************** 

assign  palignerr = palignerr_int;  //У׼�����ź�
assign  pmevld = paligned;          //����У׼����ź�
assign  pmerdy = pmerdy_int;        //����ͬ������ź�

frame_bitslip u_bitslip (
/*i*/.clk     	(pixelclk),
/*i*/.rstn    	(~arst),
/*i*/.bitslip 	(pbitslip),
/*i*/.data_in 	(datain),
/*o*/.data_out	(pdatainraw)
);

 phasealign_v1 u_phasealgin(
/*i*/.clk					(pixelclk),
/*i*/.rst_n				(~arst),
/*i*/.vin					(pdatainraw),
/*o*/.bitslip 		(pbitslip),
/*o*/.aligned 	  (paligned)
);
//8b/10b����ģ��  
decoder u_decoder(
	.pixelclk    (pixelclk),
    .pdatainbnd  (pdatainbnd),
	.potherchrdy (potherchrdy),
	.pmerdy_int  (pmerdy_int),

	.pc0         (pc0),	
	.pc1         (pc1),	
	.pvde        (pvde),	
	.pdatain	 (pdatain)
    );  

             
//�ֶ���У׼ģ��    
// phasealign #(
//     .kTimeoutMs (kTimeoutMs),   
//     .kRefClkFrqMHz (kRefClkFrqMHz),  
//     .kCtlTknCount (kCtlTknCount)  	 
// )u_phasealign(
//    .prst       (prst),
//	.arst       (arst),
//    .pixelclk   (pixelclk),
//	.refclk     (refclk),
//    .pdata      (pdatainraw),
//    .pbitslip   (pbitslip),	
//    .paligned   (paligned),
//    .perror     (palignerr_int) );

//����ͬ��ģ��
channelbond u_channelbond(
  .clk           (pixelclk),
  .rawdata       (pdatainraw),
  .iamvld        (paligned),
  .other_ch0_vld (potherchvld[0]),
  .other_ch1_vld (potherchvld[1]),
  .other_ch0_rdy (potherchrdy[0]),
  .other_ch1_rdy (potherchrdy[1]),
  .iamrdy        (pmerdy_int),
  .sdata         (pdatainbnd)
);
  
endmodule
