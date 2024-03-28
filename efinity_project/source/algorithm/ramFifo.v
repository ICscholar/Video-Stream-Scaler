`timescale 1ns / 1ps
//---------------------------Ram FIFO (RFIFO)-----------------------------
//FIFO buffer with rams as the elements, instead of data
//One ram is filled, while two others are simultaneously read out.
//Four neighboring pixels are read out at once, at the selected RAM and one line down, and at readAddress and readAddress + 1
module ramFifo #(
	parameter DATA_WIDTH = 8,
	parameter ADDRESS_WIDTH = 8,
	parameter BUFFER_SIZE = 2,
	parameter BUFFER_SIZE_WIDTH =	((BUFFER_SIZE+1) <= 2) ? 1 :	//wide enough to hold value BUFFER_SIZE + 1
									((BUFFER_SIZE+1) <= 4) ? 2 :
									((BUFFER_SIZE+1) <= 8) ? 3 :
									((BUFFER_SIZE+1) <= 16) ? 4 :
									((BUFFER_SIZE+1) <= 32) ? 5 :
									((BUFFER_SIZE+1) <= 64) ? 6 : 7
)(
	input wire 						clk,
	input wire 						rst,
	input wire						advanceRead1,	//Advance selected read RAM by one 
	input wire						advanceRead2,	//Advance selected read RAM by two   //将选中的读RAM提前两个
	input wire						advanceWrite,	//Advance selected write RAM by one
	input wire						forceRead,		//Disables writing to allow all data to be read out (RAM being written to cannot be read from normally)		//禁止写入

	input wire [DATA_WIDTH-1:0]		writeData,
	input wire [ADDRESS_WIDTH-1:0]	writeAddress,
	input wire						writeEnable,
	output reg [BUFFER_SIZE_WIDTH-1:0]
									fillCount = 0,

	//										yx
	output wire [DATA_WIDTH-1:0]	readData00,		//Read from deepest RAM (earliest data), at readAddress
	output wire [DATA_WIDTH-1:0]	readData01,		//Read from deepest RAM (earliest data), at readAddress + 1
	output wire [DATA_WIDTH-1:0]	readData10,		//Read from second deepest RAM (second earliest data), at readAddress
	output wire [DATA_WIDTH-1:0]	readData11,		//Read from second deepest RAM (second earliest data), at readAddress + 1
	input  wire [ADDRESS_WIDTH-1:0]	readAddress
);

reg [BUFFER_SIZE-1:0] writeSelect = 1;
reg [BUFFER_SIZE-1:0] readSelect = 1;

//Read select ring register
always @(posedge clk or posedge rst)
begin
	if(rst)
		readSelect <= 1;
	else
	begin
		if(advanceRead1)
		begin
			readSelect <= {readSelect[BUFFER_SIZE-2 : 0], readSelect[BUFFER_SIZE-1]};
		end
		else if(advanceRead2)
		begin
			readSelect <= {readSelect[BUFFER_SIZE-3 : 0], readSelect[BUFFER_SIZE-1:BUFFER_SIZE-2]};
		end
	end
end

//Write select ring register
always @(posedge clk or posedge rst)
begin
	if(rst)
		writeSelect <= 1;
	else
	begin
		if(advanceWrite)
		begin
			writeSelect <= {writeSelect[BUFFER_SIZE-2 : 0], writeSelect[BUFFER_SIZE-1]};
		end
	end
end

wire [DATA_WIDTH-1:0] ramDataOutA [2**BUFFER_SIZE-1:0];
wire [DATA_WIDTH-1:0] ramDataOutB [2**BUFFER_SIZE-1:0];

//Generate to instantiate the RAMs
generate
genvar i;
	for(i = 0; i < BUFFER_SIZE; i = i + 1)
		begin : ram_generate

			ramDualPort #(
				.DATA_WIDTH( DATA_WIDTH ),
				.ADDRESS_WIDTH( ADDRESS_WIDTH )
			) ram_inst_i(
				.clk( clk ),
				
				//Port A is written to as well as read from. When writing, this port cannot be read from.
				//As long as the buffer is large enough, this will not cause any problem.
				.addrA( ((writeSelect[i] == 1'b1) && !forceRead && writeEnable) ? writeAddress : readAddress ),	//&& writeEnable is 
				//to allow the full buffer to be used. After the buffer is filled, write is advanced, so writeSelect
				//and readSelect are the same. The full buffer isn't written to, so this allows the read to work properly.
				.dataA( writeData ),													
				.weA( ((writeSelect[i] == 1'b1) && !forceRead) ? writeEnable : 1'b0 ),
				.qA( ramDataOutA[2**i] ),
				
				.addrB( readAddress + 1 ),
				.dataB( 0 ),
				.weB( 1'b0 ),
				.qB( ramDataOutB[2**i] )
			);
		end
endgenerate

//Select which ram to read from
wire [BUFFER_SIZE-1:0]	readSelect0 = readSelect;
wire [BUFFER_SIZE-1:0]	readSelect1 = (readSelect << 1) | readSelect[BUFFER_SIZE-1];

//Steer the output data to the right ports
assign readData00 = ramDataOutA[readSelect0];
assign readData10 = ramDataOutA[readSelect1];
assign readData01 = ramDataOutB[readSelect0];
assign readData11 = ramDataOutB[readSelect1];

//Keep track of fill level
always @(posedge clk or posedge rst)
begin
	if(rst)
	begin
		fillCount <= 0;
	end
	else
	begin
		if(advanceWrite)
		begin
			if(advanceRead1)
				fillCount <= fillCount;
			else if(advanceRead2)
				fillCount <= fillCount - 1;
			else
				fillCount <= fillCount + 1;
		end
		else
		begin
			if(advanceRead1)
				fillCount <= fillCount - 1;
			else if(advanceRead2)
				fillCount <= fillCount - 2;
			else
				fillCount <= fillCount;
		end
	end
end

endmodule //ramFifo
