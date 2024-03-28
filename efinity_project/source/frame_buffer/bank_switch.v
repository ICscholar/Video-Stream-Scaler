

module bank_switch #(
		parameter FB_NUM = 2,
		parameter MAX_VID_WIDTH = 1920,
		parameter MAX_VID_HIGHT = 1080,
		parameter START_ADDR= 0,
		parameter VID_DATA_WIDTH= 16,
		parameter AXI_DATA_WIDTH = 256
		
)

(
input	wire		ddr_clk,
input	wire		rst_n,

input	wire		wr_sw,
input	wire		rd_sw,

output	reg	[1:0]	wr_bank,
output	reg	[1:0]	rd_bank,
output	reg			rd_sw_ack,
output	reg			wr_sw_ack,
output	reg[31:0] rd_start_addr,
output	reg[31:0]	wr_start_addr




);                       
localparam AXI_BYTE_NUMBER = AXI_DATA_WIDTH/8  ;
localparam FRAME_LEN =   MAX_VID_WIDTH*MAX_VID_HIGHT*VID_DATA_WIDTH/8 + 32'h200;  

localparam FRAME_1ST_START_ADDR = START_ADDR;
localparam FRAME_2ND_START_ADDR = FRAME_LEN + START_ADDR ;

localparam FRAME_3RD_START_ADDR = FRAME_LEN+ FRAME_2ND_START_ADDR;


	
	generate 
	if( FB_NUM == 1 ) begin : one_fb 
		always @( posedge ddr_clk or negedge rst_n ) 
		begin 
			if( !rst_n ) begin
				wr_bank <= 2'b00;
				rd_bank <= 2'b01;
				wr_sw_ack <= 1'b0;
				rd_sw_ack <= 1'b0;     
				rd_start_addr <= FRAME_1ST_START_ADDR; 
				wr_start_addr <= FRAME_1ST_START_ADDR; 
			end else begin 
				wr_bank <= 2'b00;
				rd_bank <= 2'b00;
				wr_sw_ack <= wr_sw;
				rd_sw_ack <= rd_sw;   
				rd_start_addr <= FRAME_1ST_START_ADDR;
				wr_start_addr <= FRAME_1ST_START_ADDR;
			end 
		end 

	end else if( FB_NUM == 2 ) begin :tow_fb
		reg			bank_sw_en = 1'b0;
		reg			bank_sw_en_d1 = 1'b0;
		wire		pos_bank_sw_en;
		always @( posedge ddr_clk )
		begin
			bank_sw_en <= wr_sw & rd_sw;
			bank_sw_en_d1 <= bank_sw_en;
		end
		assign pos_bank_sw_en = {bank_sw_en_d1,bank_sw_en} == 2'b01;
		
		always @( posedge ddr_clk or negedge rst_n)
		begin
			if( !rst_n ) begin
				wr_bank <= 2'b00;
				rd_bank <= 2'b01;      
				wr_start_addr <= FRAME_1ST_START_ADDR; 
				rd_start_addr <= FRAME_2ND_START_ADDR; 
			end else if( pos_bank_sw_en ) begin//必须两个bank同时切换
				wr_bank[0] <= ~wr_bank[0];
				rd_bank[0] <= wr_bank[0];
				rd_bank[1] <= 1'b0;
				wr_bank[1] <= 1'b0;      
				wr_start_addr <= wr_bank[0] ? FRAME_1ST_START_ADDR : FRAME_2ND_START_ADDR;
				rd_start_addr <= wr_bank[0] ? FRAME_2ND_START_ADDR : FRAME_1ST_START_ADDR; 
			end
		end
		
		always @( posedge ddr_clk )
		begin
			wr_sw_ack	 <= pos_bank_sw_en;
			rd_sw_ack	 <= pos_bank_sw_en;
		end
		
		
	end else if( FB_NUM == 3 ) begin :three_fb
		reg	[1:0] 	dirt_bank = 2'b10;
		reg			dirt_en = 1'b1;
		reg	[1:0]	clean_bank = 2'b00;
		reg			clean_en = 1'b0;
		wire		pos_wr_sw_en;
		wire		pos_rd_sw_en;
		reg			wr_sw_d1 = 1'b0;
		reg			rd_sw_d1 = 1'b0;
		always @( posedge ddr_clk )
		begin
				wr_sw_d1 <= wr_sw;
				rd_sw_d1 <= rd_sw;
		end
		assign pos_wr_sw_en = {wr_sw_d1,wr_sw} == 2'b01;
		assign pos_rd_sw_en = {rd_sw_d1,rd_sw} == 2'b01;
		
		always @( posedge ddr_clk )
		begin
			wr_sw_ack <= pos_wr_sw_en;
			rd_sw_ack <= pos_rd_sw_en;
		end
		always @( posedge ddr_clk or negedge rst_n)
		begin
			if( !rst_n ) begin
				wr_bank <= 2'b00;
				rd_bank <= 2'b01;
				dirt_bank <= 2'b10;
				dirt_en <= 1'b1;
				clean_en <= 1'b0;
				clean_bank <= 2'b00;    
				
				wr_start_addr <= FRAME_1ST_START_ADDR;
				rd_start_addr <= FRAME_2ND_START_ADDR; 
			end	else if( pos_wr_sw_en ) begin
						
				if( dirt_en ) begin
						wr_bank <= dirt_bank; 
						wr_start_addr <= (dirt_bank ==  2'b00) ? FRAME_1ST_START_ADDR :((dirt_bank == 2'b01)? FRAME_2ND_START_ADDR : FRAME_3RD_START_ADDR );
						clean_bank <= wr_bank;
						clean_en <= 1'b1;
						dirt_en	<= 1'b0;
				end else begin
						wr_bank <= wr_bank;
						clean_en <= clean_en;
				end
						
			end else if( pos_rd_sw_en ) begin
				if( clean_en ) begin
						rd_bank <= clean_bank;   
						rd_start_addr <= (clean_bank ==  2'b00) ? FRAME_1ST_START_ADDR :((clean_bank == 2'b01)? FRAME_2ND_START_ADDR : FRAME_3RD_START_ADDR );
						dirt_bank <= rd_bank;
						dirt_en <= 1'b1;
						clean_en <= 1'b0;
				end else begin
						rd_bank <= rd_bank;
						dirt_en <= dirt_en;
				end
				clean_en <= 1'b0;
			end
		end
						
	end
	endgenerate


endmodule
