`timescale 1ns / 1ps

//Dual port RAM
module ramDualPort #(
	parameter DATA_WIDTH = 8,
	parameter ADDRESS_WIDTH = 8
)(
	input wire [(DATA_WIDTH-1):0] dataA, dataB,
	input wire [(ADDRESS_WIDTH-1):0] addrA, addrB,
	input wire weA, weB, clk,
	output reg [(DATA_WIDTH-1):0] qA, qB
);

	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] ram[2**ADDRESS_WIDTH-1:0];

	//Port A
	always @ (posedge clk)
	begin
		if (weA) 
		begin
			ram[addrA] <= dataA;
			qA <= dataA;
		end
		else 
		begin
			qA <= ram[addrA];
		end 
	end 

	//Port B
	always @ (posedge clk)
	begin
		if (weB) 
		begin
			ram[addrB] <= dataB;
			qB <= dataB;
		end
		else 
		begin
			qB <= ram[addrB];
		end 
	end

endmodule //ramDualPort
