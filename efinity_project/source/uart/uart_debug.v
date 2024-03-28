
module uart_debug#(
			parameter CLK_RATE = 27000000,
			parameter BPS_RATE = 115200,
			parameter STOP_BIT_W = 2'b00,		//00: stop_bit = 1; 01: stop_bit = 1.5 ; 10 : stop_bit = 2
			parameter CHECKSUM_MODE = 2'b00 //00:space, 01:odd ,10:even ,11:mask
	
	
	)(
	   input 	clk,
	   input 	rxd,
	   output	txd,

	  input  		stop_bit_w ,		
	  input 		checksum_en 	,
	  input [1:0]	checksum_mode ,
	  output [7:0] 	 ram_a00_dout,
	  output [7:0] 	 ram_a01_dout,
	  output [7:0] 	 ram_a02_dout,
	  output [7:0] 	 ram_a03_dout,
	  output [7:0] 	 ram_a04_dout,
	  output [7:0] 	 ram_a05_dout,
	  output [7:0] 	 ram_a06_dout,
	  output [7:0] 	 ram_a07_dout,
	  output [7:0] 	 ram_a08_dout,
	  output [7:0] 	 ram_a09_dout  
	);
//=================================================================
//uart_cmd : (bit[0] = 1:read, bit[0] = 0 :write	)
//uart_cmd : (bit[1] = 1: read all );
//uart_cmd[2]:(= 1;=0)
localparam BPS_CNT_DATA = CLK_RATE/BPS_RATE;
	wire frame_error;
	wire checksum_error;
	wire tx_busy;
	wire [7:0]  rx_data;
	wire [7:0]  tx_data;
	wire rx_valid;
	wire fifo_rd;
	wire tx_valid;
	wire fifo_empty;
	reg fifo_empty1 = 0;
	reg fifo_empty2 = 0;
	reg [7:0] state = IDLE;
	reg rd_busy = 0;
	reg [7:0] uart_cmd = 7'd0;

	
	reg 		ram_rd_en = 1'b0;
	reg 		ram_wr_en = 1'b0;
	reg [7:0] 	ram_wr_data = 8'd0;
	wire [7:0] 	ram_rd_data;
	reg [7:0] 	ram_addr = 8'h00; 
	reg [1:0]  	wr_ack_cnt = 2'd0;
	reg [1:0] 	rd_ack_cnt = 2'd0;
	reg 		tx_valid1 = 0;
	reg 		tx_valid2 = 0;
	reg [7:0] tx_data1 = 8'd0;
	reg [7:0] tx_data2 = 8'd0;
	reg wr_ack_over=0;
	reg wr_ack_en = 0;
	reg rd_ack_over =0;
	reg rd_ack_en = 0;
//===========================================================================
//
//===========================================================================
		
	
	
	uart_tx #(
		.BPS_CNT(BPS_CNT_DATA),
		.STOP_BIT_W(STOP_BIT_W),//00: stop_bit = 1; 01: stop_bit = 1.5 ; 10 : stop_bit = 2
		.CHECKSUM_MODE(CHECKSUM_MODE)//00:space, 01:odd ,10:even ,11:mask
		)uart_tx01(
	.clk			(clk),
	.tx_data		(tx_data),
	.tx_valid		(tx_valid),
	.tx_req		(fifo_rd),
	.fifo_empty		(fifo_empty),
	.checksum_en	(checksum_en),
	.tx_over		(tx_over),
	.tx_busy		(tx_busy),
	.txd            (txd)
	);
	
	
	 uart_rx #(
	 .BPS_CNT(BPS_CNT_DATA),
	 .CHECKSUM_MODE(CHECKSUM_MODE)//00:space, 01:odd ,10:even ,11:mask
	 )uart01_rx(

	.clk			(clk),     //clk == 27M 
	.clear			(rx_valid ),
	.rxd			(rxd),
	.checksum_en	(checksum_en),
	.rx_data		(rx_data),
	.rx_valid		(rx_valid),
	.frame_error	(frame_error) 	,	     
	.checksum_error	(checksum_error) );
	
	
	 uart_debug_ram  u_uart_debug_ram(
    .clock			(clk),
    .wr_en			(ram_wr_en),
    .rd_en			(ram_rd_en),
    .addr_ptr		(ram_addr),
    .wdata_in		(ram_wr_data),
    .rdata_out  	(ram_rd_data),
    .ram_a00_dout	(ram_a00_dout),
	.ram_a01_dout	(ram_a01_dout),
	.ram_a02_dout	(ram_a02_dout),
	.ram_a03_dout	(ram_a03_dout),
	.ram_a04_dout	(ram_a04_dout),
	.ram_a05_dout	(ram_a05_dout),
	.ram_a06_dout	(ram_a06_dout),
	.ram_a07_dout	(ram_a07_dout),
	.ram_a08_dout	(ram_a08_dout),
	.ram_a09_dout	(ram_a09_dout)

);
	
	
	
	localparam IDLE 	 = 8'b0000_0000;
	localparam CMD_PAR = 8'b0000_0001;
	localparam WR_DATA = 8'b0000_0010;
	localparam RD_DATA = 8'b0000_0100;
	localparam WR_ADDR = 8'b0000_1000;
	localparam WR_RAM  = 8'b0001_0000;
	localparam RD_RAM  = 8'b0010_0000;
	localparam WAIT    = 8'b0100_0000;
	
	always @( posedge clk )
	begin
		case( state )  
		IDLE : begin 
			rd_busy <= 1'b0; 
			ram_wr_en <= 1'b0;
			ram_rd_en <= 1'b0;
			if( rx_valid ) begin
				uart_cmd <= rx_data;
				state <= CMD_PAR;
			end else begin
				state <= IDLE;
			end
		end
		CMD_PAR : begin
			if(uart_cmd == 8'hab ) begin//READ
				state <= WR_ADDR;
				rd_busy <= 1'b1; 
			end else if(uart_cmd == 8'haa )begin //WRITE
				state <= WR_ADDR;
				rd_busy <= 1'b0;
			end else begin
				state <= IDLE;
				rd_busy <= 1'b0;
			end
			
		end
		WR_ADDR : begin//解析读取地址
				
				if( rx_valid & rd_busy) begin //READ ADDR
					ram_addr <= rx_data;
					state <= RD_RAM;
				end else if( rx_valid ) begin //WRITE ADDR
					state <= WR_DATA;
					ram_addr <= rx_data;
				end else begin
					state <= WR_ADDR;
				end
		end
		RD_RAM : begin//rd
				if( rd_ack_over ) begin
					ram_rd_en <= 1'b1;
					state <= IDLE;
					rd_ack_en <= 1'b0;
				end else begin
					ram_rd_en <= 1'b1;
					rd_ack_en <= 1'b1;
					state <= RD_RAM;
				end
		end
		WR_DATA : begin//解析数据
				if( rx_valid ) begin                       
					ram_wr_data <= rx_data;
					state <= WR_RAM;       
				end else begin             
					state <= WR_DATA;       
				end     
		end  
		WR_RAM : begin //把数据写进RAM
				if( wr_ack_over ) begin
					ram_wr_en <= 1'b0;
					state <= IDLE;
					wr_ack_en <= 1'b0;
				end else begin
					ram_wr_en <= 1'b1;
					state <= WR_RAM;
					wr_ack_en <= 1'b1;
				end
		end 
		RD_DATA : begin
				if( rd_busy ) begin
					state <= IDLE;
				end else begin
					state <= RD_DATA;
				end
		end 
		default:;
		endcase                    
			
	end   
	always @( posedge clk )
	begin
		if( wr_ack_en ) begin
				wr_ack_cnt <= fifo_rd ? (wr_ack_cnt + 1'b1) : wr_ack_cnt;
				fifo_empty1 <= 1'b0;
				case( wr_ack_cnt )
				2'b00 : begin
					tx_valid1 <= fifo_rd;//
					tx_data1  <= "W";
					wr_ack_over <= 1'b0;
				end
				2'b01 : begin
					tx_valid1 <= fifo_rd;
					tx_data1  <= ram_addr;
					wr_ack_over <= 1'b0;
				end
				2'b10 : begin
					wr_ack_over <= 1'b0;
					tx_valid1 <= fifo_rd;
					tx_data1 <= ram_wr_data;
				end
				2'b11 : begin
					wr_ack_over <= 1'b1;
					tx_valid1 <= 0;
				end
				default:tx_valid1 <= 1'b0;
				endcase
			
		end else begin
				wr_ack_over <= 1'b0;
				tx_valid1 <= 1'b0;
				fifo_empty1 <= 1'b1;
				wr_ack_cnt <= 2'b00;
		end
		
				
	end    
	
	
always @( posedge clk )
	begin
		if( rd_ack_en ) begin
			rd_ack_cnt <= fifo_rd? (rd_ack_cnt + 1'b1) :rd_ack_cnt;
			fifo_empty2 <= 1'b0;
			case( rd_ack_cnt )
			2'b00 : begin
				tx_valid2 <= fifo_rd;
				tx_data2  <= "R";
				rd_ack_over <= 1'b0;
			end
			2'b01 : begin
				tx_valid2 <= fifo_rd;
				tx_data2  <= ram_addr;
				rd_ack_over <= 1'b0;
			end
			2'b10 : begin
				tx_valid2 <= fifo_rd;
				tx_data2 <= ram_rd_data;
				rd_ack_over <= 1'b0;
			end
			2'b11 : begin
				rd_ack_over <= 1'b1;
				tx_valid2 <= 1'b0;
			end
			default:tx_valid2 <= 1'b0;
			endcase
			
		end else begin
			rd_ack_over <= 1'b0;
			tx_valid2 <= 1'b0;
			fifo_empty2 <= 1'b1;
			rd_ack_cnt <= 2'b00;
		end
		
				
	end  
	
	assign  tx_valid = tx_valid1 | tx_valid2;
	assign tx_data = rd_ack_en ? tx_data2 : tx_data1;
	assign fifo_empty = fifo_empty1 & fifo_empty2;
endmodule
