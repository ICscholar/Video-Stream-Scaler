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
// File name:           i2c_edid
// Descriptions:        edidģ��
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2020/5/8 9:30:00
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module i2c_edid
(
	input wire clk,
	input wire rst,
	input wire scl,
	inout wire sda
);

//parameter define
parameter   EDID_IDLE     = 3'b000;
parameter   EDID_ADDR     = 3'b001;
parameter   EDID_ADDR_ACK = 3'b010;
parameter   EDID_ADDR_ACK2= 3'b011;
parameter   EDID_DATA     = 3'b100;
parameter   EDID_DATA_ACK = 3'b101;
parameter   EDID_DATA_ACK2= 3'b110;

//reg define
reg         hiz ;
reg         sda_out;
reg [4:0]   count;
reg [15:0]  rdata;
reg [7:0]   addr;
reg [7:0]   data ;
 (* keep="true" *)reg [2:0]   edid_state;
reg [3:0]   scl_data ;
reg [3:0]   sda_data ;

//wire define
wire [7:0]  dout;
wire        scl_high;
wire        scl_negedge;
wire        scl_posedge;

//*****************************************************
//**                    main code
//***************************************************** 
     
//ȡIICʱ�ӵ�������
assign scl_posedge = (scl_data == 4'b0111) ? 1'b1 : 1'b0;
//ȡIICʱ�ӵ��½���
assign scl_negedge = (scl_data == 4'b1000) ? 1'b1 : 1'b0;
//IICʱ�ӵ�ȫ�ߵ�ƽ
assign scl_high    = (scl_data == 4'b1111) ? 1'b1 : 1'b0;
//IIC���ݵ���̬���
assign sda = hiz ? 1'hz : sda_out;

//�洢edid��Ϣ
edid_rom edid_rom_0 (
	.addra(addr[7:0]),
	.clka(clk),
	.douta(dout)
);

always @(posedge clk) begin
	if (rst) begin
		hiz <= 1'b1;
		sda_out <= 1'b0;
		count <= 5'd0;
		rdata <= 24'h0;
		addr <= 8'h0;
		data <= 8'h0;
		scl_data <= 4'h00;
		sda_data <= 4'h00;
	end else begin
		scl_data <= {scl_data[2:0], scl};
		sda_data <= {sda_data[2:0], sda};

		if (sda_data == 4'b1000 && scl_high) begin		   // iic��ʼ�ı�־
			count <= 5'd0;
			hiz <= 1'b1;
			sda_out <= 1'b0;
			edid_state <= EDID_ADDR;
		end else if (sda_data == 4'b0111 && scl_high) begin	// iic�����ı�־
			edid_state <= EDID_IDLE;
		end else
		case (edid_state)
		EDID_IDLE: begin
			hiz <= 1'b1;
			sda_out <= 1'b0;		
		end
		EDID_ADDR: begin
			if (scl_posedge) begin
				count <= count + 5'd1;
				rdata  <= {rdata[14:0], sda};
				if (count[2:0] == 3'd7) begin      //������ַд��
					edid_state <= EDID_ADDR_ACK;				
					if (count == 5'd15)            //�ֵ�ַд��    
						addr <= {rdata[6:0],sda};  //���ֵ�ַ����ROM��ַ
				    else 
						addr <= addr;		
				end
			end
		end
		EDID_ADDR_ACK: begin
			if (scl_negedge) begin
				hiz <= 1'b0;
				sda_out <= 1'b0;
				if (count == 5'd8 && rdata [0] == 1'b1) begin //�ж��Ƿ��Ƕ�����
					data <= dout;
					edid_state <= EDID_DATA;
				end else begin
					edid_state <= EDID_ADDR_ACK2;
				end
			end
		end
		EDID_ADDR_ACK2: begin
			if (scl_negedge) begin
				hiz <= 1'b1;          //�ͷ�����
				edid_state <= EDID_ADDR; 
			end
		end
		EDID_DATA: begin
			if (scl_negedge) begin
				count <= count + 5'd1;
				hiz <= 1'b0;
				sda_out <= data[7];            
				data <= {data[6:0], 1'b0};     //������λ
				if (count[2:0] == 3'd7) begin  //һ�����ݶ���
					addr <= addr + 8'h1;       //rom��ַ��1
					edid_state <= EDID_DATA_ACK; 
				end
			end
		end
		EDID_DATA_ACK: begin
			if (scl_negedge) begin
				data <= dout;
				hiz <= 1'b1;       //�ͷ�����
				sda_out <= 1'b0;
				edid_state <= EDID_DATA_ACK2;
			end
		end
		EDID_DATA_ACK2: begin
			if (scl_posedge) begin
				if (sda)  //����Ϊ1��������������Ϊ0��δ����
					edid_state <= EDID_IDLE;  
				else
					edid_state <= EDID_DATA;
			end
		end
		endcase
	end
end

endmodule // edid