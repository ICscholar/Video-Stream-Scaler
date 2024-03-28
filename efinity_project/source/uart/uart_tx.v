module uart_tx #(
	parameter BPS_CNT = 100,
	parameter STOP_BIT_W = 2'b00, 		//00: stop_bit = 1; 01: stop_bit = 1.5 ; 10 : stop_bit = 2
	parameter CHECKSUM_MODE = 2'b00,	//00:space, 01:odd ,10:even ,11:mask
	parameter CHECKSUM_EN = 1'b0
)(
	input clk,   //clk == 27M 
	input [7:0] tx_data,
	input 			tx_valid,//tx_valid之后三个时钟之内不检测tx_req
	output tx_req,
	output tx_over,
	output reg tx_busy,
	output txd
);
	
reg rd_en_r = 0;
reg [3:0] bite_cnt = 0;

always @( posedge clk )
begin
	if( {tx_busy,bite_cnt} == 5'b00000 )
		rd_en_r  <= 1'b1;
	else if( tx_valid )
		rd_en_r <= 1'b0;
	else
		rd_en_r <= 1'b0;
end

assign tx_req = rd_en_r ;

reg tx_over_r =0;
reg [3:0] BIT_NUM = 0;   
// reg tx_busy = 0;   
reg [7:0] tx_data_r= 0;
always @( posedge clk )
begin
	if( CHECKSUM_EN )
		BIT_NUM <= 10;
	else
		BIT_NUM <= 9;
end
	
reg [7:0] tx_valid_dly = 0;

always @( posedge clk )
begin
		tx_valid_dly <= {tx_valid_dly[6:0],tx_valid};
end

//only when new data come can tx_data_r update
always @( posedge clk )
begin
	if( tx_valid )
		tx_data_r <= tx_data;
end

always @( posedge clk )
begin
	if( tx_valid_dly[0] )
		tx_busy <= 1'b1;
	else if( tx_over_r )
		tx_busy <= 1'b0;
	else
		tx_busy <= tx_busy;
end

reg [15:0] tx_cnt =0;
always @( posedge clk )
begin
	if( ~tx_busy )
		tx_cnt <= 0;
	else if( tx_cnt == BPS_CNT-1 )
		tx_cnt <= 0;
	else
		tx_cnt <= tx_cnt + 1'b1;
end
	
wire bit_cnt_en ;
reg [3:0] bit_cnt = 0;
assign bit_cnt_en = (tx_cnt == BPS_CNT-1);

always @( posedge clk )
begin
	if(~tx_busy)
		bite_cnt <= 0;
	else if( bit_cnt_en )
		bite_cnt <= bite_cnt + 1'b1;
end
	
always @( posedge clk )
begin
	case({CHECKSUM_EN,STOP_BIT_W})
		3'b000 :tx_over_r <=( ( tx_cnt == BPS_CNT-1 )&&(bite_cnt == BIT_NUM));
		3'b001 :tx_over_r <= ( tx_cnt == BPS_CNT/2-1 )&&(bite_cnt == BIT_NUM+1);
		3'b010 :tx_over_r <= ( tx_cnt == BPS_CNT-1 )&&(bite_cnt == BIT_NUM+1);
		3'b100 :tx_over_r <= ( tx_cnt == BPS_CNT-1 )&&(bite_cnt == BIT_NUM);
		3'b101 :tx_over_r <= ( tx_cnt == BPS_CNT/2-1 )&&(bite_cnt == BIT_NUM+1);
		3'b110 :tx_over_r <= ( tx_cnt == BPS_CNT-1 )&&(bite_cnt == BIT_NUM+1);
		default:;
	endcase
end

assign tx_over = tx_over_r;
reg checksum = 0;  
reg txd_r =1;

always @( posedge clk )
begin
	case( {tx_busy,bite_cnt })
		5'h10 :txd_r <= 1'b0;
		5'h11 :txd_r <= tx_data_r[0];
		5'h12 :txd_r <= tx_data_r[1];
		5'h13 :txd_r <= tx_data_r[2];
		5'h14 :txd_r <= tx_data_r[3];
		5'h15 :txd_r <= tx_data_r[4];
		5'h16 :txd_r <= tx_data_r[5];
		5'h17 :txd_r <= tx_data_r[6];
		5'h18 :txd_r <= tx_data_r[7];
		5'h19 :txd_r <= CHECKSUM_EN ? checksum :1'b1;
		5'h1A :txd_r <= 1;
		5'h1B :txd_r <= 1;
		default :txd_r <=1;
	endcase
end

assign txd = txd_r;

always @(posedge clk )
begin
	case( CHECKSUM_MODE )
	2'b00 :checksum <= 1'b0;
	2'b01 :checksum <= ~^tx_data_r;
	2'b10 :checksum <= ^tx_data_r;
	2'b11 :checksum <= 1'b1;
	default:;
	endcase
end
	
endmodule