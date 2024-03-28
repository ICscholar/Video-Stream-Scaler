/////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2013-2018 Efinix Inc. All rights reserved.
//
// True Dual Port RAM
//
//*******************************
//	Revisions:
//	0.0 Initial rev
//	0.1 Added output register
//	1.0 Finalized RTL macro
//*******************************

module true_dual_port_ram
#(
	parameter DATA_WIDTH	= 8,
	parameter ADDR_WIDTH	= 9,
	parameter WRITE_MODE_1	= "READ_FIRST",	// WRITE_FIRST, READ_FIRST, NO_CHANGE
	parameter WRITE_MODE_2	= "READ_FIRST",
	parameter OUTPUT_REG_1	= "FALSE",
	parameter OUTPUT_REG_2	= "FALSE",
	parameter RAM_INIT_FILE	= "ram_init_file.mem",
	parameter RAM_INIT_RADIX= "HEX"
)
(
	input we1, we2, clka, clkb,
	input [DATA_WIDTH-1:0] din1, din2,
	input [ADDR_WIDTH-1:0] addr1, addr2,
	output[DATA_WIDTH-1:0] dout1, dout2
);

	localparam MEMORY_DEPTH = 2**ADDR_WIDTH;
	localparam MAX_DATA = (1<<ADDR_WIDTH)-1;
	
	reg [DATA_WIDTH-1:0] ram [MEMORY_DEPTH-1:0];
	
	reg [DATA_WIDTH-1:0] r_dout1_1P;
	reg [DATA_WIDTH-1:0] r_dout2_1P;

	reg [DATA_WIDTH-1:0] r_dout1_2P;
	reg [DATA_WIDTH-1:0] r_dout2_2P;
	
	integer i;
	initial
	begin
//	// By default the Efinix memory will initialize to 0
		if (RAM_INIT_FILE != "")
		begin
			if (RAM_INIT_RADIX == "BIN")
				$readmemb(RAM_INIT_FILE, ram);
			else
				$readmemh(RAM_INIT_FILE, ram);
		end
	end
	
	generate
		if (WRITE_MODE_1 == "WRITE_FIRST")
		begin
			always@(posedge clka)
			begin
				if (we1)
				begin
					ram[addr1]	<= din1;
					r_dout1_1P	<= din1;
				end
				else
					r_dout1_1P	<= ram[addr1];
			end
		end
		else if (WRITE_MODE_1 == "READ_FIRST")
		begin
			always@(posedge clka)
			begin
				if (we1)
					ram[addr1]	<= din1;
				r_dout1_1P	<= ram[addr1];
			end
		end
		else if (WRITE_MODE_1 == "NO_CHANGE")
		begin
			always@(posedge clka)
			begin
				if (we1)
					ram[addr1]	<= din1;
				else
					r_dout1_1P	<= ram[addr1];
			end
		end
		
		if (WRITE_MODE_2 == "WRITE_FIRST")
		begin
			always@(posedge clkb)
			begin
				if (we2)
				begin
					ram[addr2]	<= din2;
					r_dout2_1P	<= din2;
				end
				else
					r_dout2_1P	<= ram[addr2];
			end
		end
		else if (WRITE_MODE_2 == "READ_FIRST")
		begin
			always@(posedge clkb)
			begin
				if (we2)
					ram[addr2]	<= din2;
				r_dout2_1P	<= ram[addr2];
			end
		end
		else if (WRITE_MODE_2 == "NO_CHANGE")
		begin
			always@(posedge clkb)
			begin
				if (we2)
					ram[addr2]	<= din2;
				else
					r_dout2_1P	<= ram[addr2];
			end
		end

		if (OUTPUT_REG_1 == "TRUE")
		begin
			always@(posedge clka)
				r_dout1_2P	<= r_dout1_1P;
			
			assign dout1 = r_dout1_2P;
		end
		else
			assign dout1 = r_dout1_1P;
		
		if (OUTPUT_REG_2 == "TRUE")
		begin
			always@(posedge clkb)
				r_dout2_2P	<= r_dout2_1P;

			assign dout2 = r_dout2_2P;
		end
		else
			assign dout2 = r_dout2_1P;
	endgenerate
	
endmodule
