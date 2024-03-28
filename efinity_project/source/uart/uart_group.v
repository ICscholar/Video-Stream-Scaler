/*
rev:1.1 date210714 add the BSP_RATE,CLK_RATE,BSP_CNT_DATA parameter
*/

	module  uart_group #(
			parameter CLK_RATE = 27000000,
			parameter BPS_RATE = 115200,
			parameter STOP_BIT_W = 2'b00,		//00: stop_bit = 1; 01: stop_bit = 1.5 ; 10 : stop_bit = 2
			parameter CHECKSUM_MODE = 2'b00 //00:space, 01:odd ,10:even ,11:mask
	
	
	)(
	   input 					clk,
	   input 					rxd_fifo_rd,
	   input 					rxd_fifo_aclr,
	   output 				rxd_fifo_empty,
	   output 				rxd_fifo_full,
	   output [7:0] 	rxd_fifo_q,
	   input 					txd_fifo_wr,
	   input 					txd_fifo_aclr,
	   input [7:0] 		txd_fifo_data,
	   output 				txd_fifo_full,
	   output 				txd_fifo_empty,
	   input 					uart_rx_en	,	//when asserted ,uart recive enable,			
	   input 					uart_tx_en	,				
	   input 					checksum_en 	,
	   input					iq_en,      
	   input					uart_rst, 
	   output		[4:0]	uart_state ,
	   output					irq,
	   input 					rxd,
	   output					txd
	   
	);
	localparam BPS_CNT_DATA = CLK_RATE/BPS_RATE;
	reg irq_r = 0;
 
	wire [3:0] rx_state;  
	wire frame_error;
	wire checksum_error;
	

		wire [7:0]  rx_data;
		wire [7:0]  tx_data;
		wire rx_valid;
		//wire txd_fifo_empty;
		wire txd_fifo_rd;
		reg tx_valid = 0;
		always @( posedge clk )
		begin
				tx_valid <= txd_fifo_rd;
		end
		
		fifo_w8 	fifo_w8_tx (
	.aclr ( |{uart_rst,{~uart_tx_en}} ),
	.data ( txd_fifo_data ),
	.rdclk ( clk ),
	.rdreq ( txd_fifo_rd ),
	.wrclk ( clk ),
	.wrreq ( &{txd_fifo_wr,uart_tx_en} ),
	.q ( tx_data ),
	.rdempty ( txd_fifo_empty ),
	.wrfull ( txd_fifo_full )
	);
	
		uart_tx #(
		.BPS_CNT(BPS_CNT_DATA),
		.STOP_BIT_W(STOP_BIT_W),//00: stop_bit = 1; 01: stop_bit = 1.5 ; 10 : stop_bit = 2
		.CHECKSUM_MODE(CHECKSUM_MODE)//00:space, 01:odd ,10:even ,11:mask
		)uart_tx01(
		/*I*/.clk			(clk),
		/*I*/.tx_data		(tx_data),
		/*I*/.tx_valid		(tx_valid),
		/*o*/.fifo_rd		(txd_fifo_rd),
		/*I*/.fifo_empty		(txd_fifo_empty),
		/*I*/.checksum_en	(checksum_en),
		/*O*/.tx_over		(),
		/*O*/.txd            (txd)
		);
	
	
	 uart_rx #(
	 .BPS_CNT(BPS_CNT_DATA),
	 .CHECKSUM_MODE(CHECKSUM_MODE)//00:space, 01:odd ,10:even ,11:mask
	 )uart01_rx(
	.clk			(clk),     //clk == 27M 
	.clear			(rx_valid ),
	.rxd			(rxd),
	.checksum_en	(checksum_end),
	.rx_data		(rx_data),
	.rx_valid		(rx_valid),
	.frame_error	(frame_error) 	,	     
	.checksum_error	(checksum_error) );
	
	fifo_w8	fifo_w8_rx (
	.aclr ( |{uart_rst ,{~uart_rx_en}}  ),
	.data ( rx_data ),
	.rdclk ( clk ),
	.rdreq ( rxd_fifo_rd ),
	.wrclk ( clk ),
	.wrreq ( &{uart_rx_en,rx_valid,iq_en} ),
	.q ( rxd_fifo_q ),
	.rdempty ( rxd_fifo_empty ),
	.wrfull ( rxd_fifo_full )
	);
	//bit 7  fifo have data
	reg [2:0] error = 3'b00;
	wire txd_fifo_unempty;
	assign txd_fifo_unempty = ~txd_fifo_empty;
	assign uart_state = {error,1'b0,txd_fifo_unempty};
	
	always @( posedge clk )
	begin
			if( |{rxd_fifo_full,txd_fifo_full})
					error <= 3'b001;
//			else if( frame_error    )
//					error <= 3'b010;
//			else if(checksum_error)
//					error <= 3'b011;
			else 
					error <= 3'b000;
	end
	//generate the irq siganl
	always @( posedge clk )
	begin
			if( ~iq_en )
				irq_r <= 1'b0;
			else if(~rxd_fifo_empty)
				irq_r <= 1'b1;
			else if( txd_fifo_full )
				irq_r <= 1'b1;
			else if( error != 0 )
				irq_r <= 1'b1;
			else 
				irq_r <= 1'b0;
	end  
	
	assign irq = irq_r;
	
	endmodule
	