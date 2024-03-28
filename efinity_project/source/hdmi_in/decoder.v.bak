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
// File name:           decoder
// Descriptions:        8b/10b解码模块
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2020/5/8 9:30:00
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************

module decoder(
	input			pixelclk,
    input	[9:0]	pdatainbnd,
	input	[1:0]	potherchrdy,
	input			pmerdy_int,
	
	output			pc0,	
	output			pc1,	
	output			pvde,	
	output	[7:0]	pdatain	
    );

//parameter define 	
parameter CTRLTOKEN0 = 10'b1101010100;
parameter CTRLTOKEN1 = 10'b0010101011;
parameter CTRLTOKEN2 = 10'b0101010100;
parameter CTRLTOKEN3 = 10'b1010101011;

//wire define 
wire	[7:0]	pdatain8b; 

//reg define 
reg	[7:0]	pdatain =0; 
reg			pc0 =0;	
reg			pc1 =0;	
reg			pvde=0;	

//*****************************************************
//**                    main code
//***************************************************** 

assign pdatain8b = (pdatainbnd[9]) ? ~pdatainbnd[7:0] : pdatainbnd[7:0];                
                                                                                          
always @ (posedge pixelclk) begin                                                       
    if(pmerdy_int && (potherchrdy == 2'b11)) begin                                        
        case (pdatainbnd)                                                                   
            CTRLTOKEN0: begin                                                                 
                pc0 <=#1 1'b0;                                                                  
                pc1 <=#1 1'b0;                                                                  
                pvde <=#1 1'b0;                                                                 
            end                                                                               
                                                                                              
            CTRLTOKEN1: begin                                                                 
                pc0 <=#1 1'b1;                                                                  
                pc1 <=#1 1'b0;                                                                  
                pvde <=#1 1'b0;                                                                 
            end                                                                               
                                                                                              
            CTRLTOKEN2: begin                                                                 
                pc0 <=#1 1'b0;                                                                  
                pc1 <=#1 1'b1;                                                                  
                pvde <=#1 1'b0;                                                                 
            end                                                                               
                                                                                              
            CTRLTOKEN3: begin                                                                 
                pc0 <=#1 1'b1;                                                                  
                pc1 <=#1 1'b1;                                                                  
                pvde <=#1 1'b0;                                                                 
            end                                                                               
                                                                                              
            default: begin                                                                    
                pdatain[0] <=#1 pdatain8b[0];                                                                               
                pdatain[1] <=#1 (pdatainbnd[8]) ? (pdatain8b[1] ^ pdatain8b[0]) : (pdatain8b[1] ~^ pdatain8b[0]);           
                pdatain[2] <=#1 (pdatainbnd[8]) ? (pdatain8b[2] ^ pdatain8b[1]) : (pdatain8b[2] ~^ pdatain8b[1]);           
                pdatain[3] <=#1 (pdatainbnd[8]) ? (pdatain8b[3] ^ pdatain8b[2]) : (pdatain8b[3] ~^ pdatain8b[2]);           
                pdatain[4] <=#1 (pdatainbnd[8]) ? (pdatain8b[4] ^ pdatain8b[3]) : (pdatain8b[4] ~^ pdatain8b[3]);           
                pdatain[5] <=#1 (pdatainbnd[8]) ? (pdatain8b[5] ^ pdatain8b[4]) : (pdatain8b[5] ~^ pdatain8b[4]);           
                pdatain[6] <=#1 (pdatainbnd[8]) ? (pdatain8b[6] ^ pdatain8b[5]) : (pdatain8b[6] ~^ pdatain8b[5]);           
                pdatain[7] <=#1 (pdatainbnd[8]) ? (pdatain8b[7] ^ pdatain8b[6]) : (pdatain8b[7] ~^ pdatain8b[6]);           
                                                                                             
                pvde <=#1 1'b1;                                                                
            end                                                                              
        endcase                                                                                                                                                                                      
    end 
    else begin                                                                       
        pc0 <= 1'b0;                                                                       
        pc1 <= 1'b0;                                                                       
        pvde <= 1'b0;
        pdatain <= 8'h0;
    end
end	

endmodule
