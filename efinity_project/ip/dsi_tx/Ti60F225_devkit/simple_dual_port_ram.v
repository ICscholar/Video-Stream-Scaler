/////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2013-2018 Efinix Inc. All rights reserved.
//
// Single RAM block
//
// *******************************
// Revisions:
// 0.0 Initial rev
// 0.1 Added output register
// 1.0 Finalized RTL macro
// *******************************

module simple_dual_port_ram
#(
	parameter DATA_WIDTH	= 8,
	parameter ADDR_WIDTH	= 9,
	parameter OUTPUT_REG	= "TRUE",
	parameter RAM_INIT_FILE	= "",
	parameter RAM_INIT_RADIX= "HEX"
)
(
	input [(DATA_WIDTH-1):0] wdata,
	input [(ADDR_WIDTH-1):0] waddr, raddr,
	input we, wclk, re, rclk,
	output [(DATA_WIDTH-1):0] rdata
);

	localparam MEMORY_DEPTH = 2**ADDR_WIDTH;
	localparam MAX_DATA = (1<<ADDR_WIDTH)-1;
	
	reg [DATA_WIDTH-1:0] ram[MEMORY_DEPTH-1:0];
	reg [DATA_WIDTH-1:0] r_rdata_1P;
	reg [DATA_WIDTH-1:0] r_rdata_2P;

	initial
	begin
	// By default the Efinix memory will initialize to 0
		if (RAM_INIT_FILE != "")
		begin
			if (RAM_INIT_RADIX == "BIN")
				$readmemb(RAM_INIT_FILE, ram);
			else
				$readmemh(RAM_INIT_FILE, ram);
		end
	end
	
	always @ (posedge wclk)
		if (we)
		ram[waddr] <= wdata;
	
	always @ (posedge rclk)
	begin
		if (re)
			r_rdata_1P <= ram[raddr];
		r_rdata_2P <= r_rdata_1P;
	end
	
	generate
		if (OUTPUT_REG == "TRUE")
			assign	rdata = r_rdata_2P;
		else
			assign	rdata = r_rdata_1P;
	endgenerate

endmodule

