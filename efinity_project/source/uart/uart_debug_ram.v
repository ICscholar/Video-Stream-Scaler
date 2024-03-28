

module uart_debug_ram #(
 //  parameter NUMBER_OF_MIF_RANGE          = 6,
 //   parameter ROM_DEPTH_FOR_EACH_MIF_RANGE = 7,			      
    parameter ROM_SIZE                     = 32,   
    parameter TOTAL_ROM_DEPTH              = 128, // 6*7
    parameter ADDR_WIDTH                   = 8   // alt_clogb2(42) 
) (
    clock,
    wr_en,
    rd_en,
    addr_ptr,
    wdata_in,
    rdata_out,
    ram_a00_dout,
    ram_a01_dout,
    ram_a02_dout,
    ram_a03_dout,
    ram_a04_dout,
    ram_a05_dout,
    ram_a06_dout,
    ram_a07_dout,
    ram_a08_dout,
    ram_a09_dout
    
    
);
		input            clock;
    input   				 wr_en;
    input  					 rd_en;
    input   [ADDR_WIDTH-1:0] addr_ptr;
    input   [ROM_SIZE-1:0]   wdata_in;
    output  [ROM_SIZE-1:0]   rdata_out;
    output  [ROM_SIZE-1:0] 	 ram_a00_dout;
    output  [ROM_SIZE-1:0] 	 ram_a01_dout;
    output  [ROM_SIZE-1:0] 	 ram_a02_dout;
    output  [ROM_SIZE-1:0] 	 ram_a03_dout;
    output  [ROM_SIZE-1:0] 	 ram_a04_dout;
    output  [ROM_SIZE-1:0] 	 ram_a05_dout;
    output  [ROM_SIZE-1:0] 	 ram_a06_dout;
    output  [ROM_SIZE-1:0] 	 ram_a07_dout;
    output  [ROM_SIZE-1:0] 	 ram_a08_dout;
    output  [ROM_SIZE-1:0] 	 ram_a09_dout;

     
reg [ROM_SIZE-1:0]   rdata_out  ;
reg [ROM_SIZE-1:0] 	 ram_a00_dout = 32'h8900_0000;
reg [ROM_SIZE-1:0] 	 ram_a01_dout = 32'h8000_0000;
reg [ROM_SIZE-1:0] 	 ram_a02_dout = 32'h0080_0080;
reg [ROM_SIZE-1:0] 	 ram_a03_dout = 32'h0000_0000;//mirror 8'h00 = passthrough 8'h01 : h_mirror ; 8'h2 : v_mirror ; 8'h03 : center_mirror;
reg [ROM_SIZE-1:0] 	 ram_a04_dout = 32'h0600_0000;
reg [ROM_SIZE-1:0] 	 ram_a05_dout = 32'h1000_0000;
reg [ROM_SIZE-1:0] 	 ram_a06_dout = 32'h2c00_0000;
reg [ROM_SIZE-1:0] 	 ram_a07_dout = 32'h1600_0000;
reg [ROM_SIZE-1:0] 	 ram_a08_dout = 32'h2e00_0000;
reg [ROM_SIZE-1:0] 	 ram_a09_dout = 32'h5800_0000;


always @( posedge clock )
begin
		if( wr_en ) begin
				case( addr_ptr )
					7'h00 : begin	ram_a00_dout <= wdata_in;	end 
					7'h01 : begin	ram_a01_dout <= wdata_in;	end
					7'h02 : begin	ram_a02_dout <= wdata_in;	end 
					7'h03 : begin	ram_a03_dout <= wdata_in;	end 
					7'h04 : begin	ram_a04_dout <= wdata_in;	end 
					7'h05 : begin	ram_a05_dout <= wdata_in;	end 
					7'h06 : begin	ram_a06_dout <= wdata_in;	end 
					7'h07 : begin	ram_a07_dout <= wdata_in;	end 
					7'h08 : begin	ram_a08_dout <= wdata_in;	end 
					7'h09 : begin	ram_a09_dout <= wdata_in;	end 
					default:;
				endcase
		end
end

always @( posedge clock )
begin
		if( rd_en ) begin
				case( addr_ptr )
					7'h00 : begin	rdata_out <= ram_a00_dout;	end 
					7'h01 : begin	rdata_out <= ram_a01_dout;	end
					7'h02 : begin	rdata_out <= ram_a02_dout;	end 
					7'h03 : begin	rdata_out <= ram_a03_dout;	end 
					7'h04 : begin	rdata_out <= ram_a04_dout;	end 
					7'h05 : begin	rdata_out <= ram_a05_dout;	end 
					7'h06 : begin	rdata_out <= ram_a06_dout;	end 
					7'h07 : begin	rdata_out <= ram_a07_dout;	end 
					7'h08 : begin	rdata_out <= ram_a08_dout;	end 
					7'h09 : begin	rdata_out <= ram_a09_dout;	end 
					default:;
				endcase
		end
end



endmodule			      


